# Sapphire speaker silence, 2026-10-23

## Finding

The best supported software cause is an omitted FS1815 volume-control write. The iOS port powers both chips but never performs the `fsm_config_vol` step in the stock driver's `fs1815_start_up`. That step writes register `0x06` with `0xff00` at the default maximum volume. Patch 1018 restores only this step behind `sapphire_fs_vol=1`, default off. A phone boot is required to establish whether it restores sound.

## Evidence

- The `ref1.txt` boot uses `sapphire_amp=1 sapphire_spk=1 sapphire_spk_fix=1 sapphire_spk_xm=1 sapphire_spk_ref=1 adsp_tone=3` (`/home/fryad/ios-build/logs/ref1.txt:312`). SPF becomes ready (`:420`), the graph opens (`:577`), both FS1815 chips identify as `0x0012` (`:666-670`), and both report `power on err=0` (`:676`, `:681`). The tone and iOS stream start (`:786`, `:2868`).
- RX macro, WCD, and SoundWire readbacks match the Android playback capture at startup and after 500 ms. Examples: RX `0x1180=0x70`, `0x1400=0x24`, `0x1500=0x24` (`ref1.txt:750`, `:753`, `:761`); WCD `0x3008=0xc3`, `0x300a=0xc0`, `0x3128=0x80` (`:766-773`); and both PA hardware status registers match (`:771-774`). The later checks are at `:900-934`.
- Both amplifier status readbacks remain different while playing. At startup and after 500 ms, `0x34` and `0x35` each read `ANASTAT 0x03=0000` and `DIGSTAT 0x04=0180` (`ref1.txt:782-785`, `:935-938`). Working Android reads `000d` and `7580` on both (`/home/fryad/ios-build/android-ref/fs-play2.txt:4-7`, `:25-28`); idle Android reads `0000` and `0080` (`fs-idle.txt:4-7`, `:25-28`). The iOS registers show the requested power state (`PWRCTRL 0x10=0000`, `SYSCTRL 0x11=008f`, `ref1.txt:689-690`, `:701-702`), but those writes do not establish that the amplifier is amplifying.
- [FourSemi's FS1815 source](https://github.com/Nikita-Projects/android_kernel_xiaomi_sm6225-modules/blob/HEAD/qcom/opensource/audio-kernel/asoc/codecs/fs1815/fs1815.c#L121-L139) calls `fsm_config_vol` after writing `SYSCTRL=008f` and `PWRCTRL=0000`. [The helper](https://github.com/Nikita-Projects/android_kernel_xiaomi_sm6225-modules/blob/HEAD/qcom/opensource/audio-kernel/asoc/codecs/fs1815/fsm_core.c#L1141-L1169) writes `0x06` with `cfg->volume << 8`, capped at `0xff`. The stock, symbol-bearing `fs1815_dlkm.ko` confirms `fs1815_start_up+0x64` calls `fsm_config_vol` (relocation at `0x08d8`). The port's `sapphire_fs_start` goes directly from `PWRCTRL=0000` to its delay (`xnu/patches/1015-sapphire-android-reference.patch:371-379`).
- `ref1.txt:1072` says `tone: DSP position frame 3296 index 56832` after a 3-second tone. Earlier logs say about `3000` after the same test (`/home/fryad/ios-build/logs/amp1.txt:813`, `snd2.txt:797`), so this counter is consistent with elapsed milliseconds. It does not prove a DSP stall.

## One test boot

Keep the boot arguments from `ref1.txt` and add `sapphire_fs_vol=1`. With `adsp_tone=3`, the first test is the boot tone; later playback is a second observation from the same boot.

If the missing volume write is the cause, the log should show `sapphire_fs_vol=1`, then one `VOLCTRL 06` line for each of `0x34` and `0x35` with `new=ff00 read_err=0`, followed by `power on err=0`, `active mask=0x3`, and an audible 3-second tone. The `spk ref start` and `+500ms` amp status lines should move toward Android's `03=000d`, `04=7580`; if they do not, audible sound still decides whether those bits are a reliable proxy for output.

If both `VOLCTRL` readbacks are `ff00` but the tone is silent, the missing volume write was real but is insufficient. If `VOLCTRL` does not read back `ff00`, the I2C write or register interpretation failed, and patch 1018 will log a nonzero `power on err` and keep that amp out of the active mask. If the amp status values remain `0000/0180`, inspect the FS1815 analog input and supply path next, because the upstream codec readbacks already match Android.

Patch validation: `git apply --check` and `git apply` succeeded after applying patches `1006` through `1015` in filename order to a fresh copy of the source tagged `sapphire-1005`. No phone boot or acoustic measurement was available.

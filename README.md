# OSBUNK — Bunker Operating System

Современная ОС для управления бункером на CC:Tweaked для Minecraft 1.21.1.

## Что внутри

- рабочий стол в стиле компьютерной ОС;
- PIN-защита;
- управление дверью, светом, вентиляцией и тревогой;
- аварийный `LOCKDOWN`;
- поддержка монитора и touchscreen;
- Hardware Center с автоматическим обнаружением периферии;
- modem / Rednet;
- Printer и печать системного отчёта;
- Disk Drive и проверка диска;
- Speaker для системных уведомлений;
- файловый менеджер;
- встроенная консоль CC:Tweaked;
- журнал событий;
- автоматический `startup.lua`;
- резервная копия старого `startup.lua`, `bunker.lua` и `config.lua` при установке.

Официальная документация CC:Tweaked для Minecraft 1.21.1 показывает актуальную ветку 1.120.2; в ней доступны периферийные API для monitor, modem, printer, drive и speaker. citeturn887939search4turn887939search3

## Установка

В компьютере CC:Tweaked с включённым HTTP API:

```text
wget run https://raw.githubusercontent.com/Frez7373/POBUNK/main/install.lua
```

После установки перезапусти компьютер. ОС стартует через `/startup.lua`.

## PIN

По умолчанию: `2580`.

Измени его в `/config.lua` после установки.

## Стандартная разводка redstone

- `front` — дверь;
- `back` — освещение;
- `left` — вентиляция;
- `bottom` — тревога.

Стороны можно изменить в `/config.lua`.

## Аппаратное обеспечение

OSBUNK не требует фиксированных сторон для устройств: периферия определяется через `peripheral.getNames()` / `peripheral.getType()`. Для совместимой периферии CC:Tweaked поддерживает в том числе monitor, drive, modem, printer и speaker. citeturn887939search6turn887939search2turn887939search0

## Резерв

При установке старые `startup.lua`, `bunker.lua` и `config.lua` сохраняются в `/osbunk_backup` на компьютере.

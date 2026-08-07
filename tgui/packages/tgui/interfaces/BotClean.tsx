import { useBackend } from '../backend';
import { Button, Box } from '../components';
import { Window } from '../layouts';

import '../styles/BotClean.scss';

type CleanBotData = {
  cleanblood: boolean;
  locked: boolean;
  noaccess: boolean;
  maintpanel: boolean;
  on: boolean;
  autopatrol: boolean;
  canhack: boolean;
  emagged: boolean;
  remote_disabled: boolean;
  painame: string;
  health: number;
  maxhealth: number;
};

export const BotClean = () => {
  const { act, data } = useBackend<CleanBotData>();

  const {
    locked,
    noaccess,
    maintpanel,
    on,
    autopatrol,
    canhack,
    emagged,
    remote_disabled,
    painame,
    cleanblood,
    health,
    maxhealth,
  } = data;

  const healthPercent =
    maxhealth > 0
      ? Math.max(0, Math.min(100, (health / maxhealth) * 100))
      : 0;

  return (
    <Window width={670} height={600}>
    <Window.Content className="cleanBot">

      <Box className="header">

        <Box className="title">
          УБОРОЧНЫЙ БОТ
        </Box>

        <Box className="sub">
          CLEANING SUPPORT SYSTEM v1.1
        </Box>

      </Box>

      <Box className="systemCore">

        <Box
          className={
            on
              ? 'coreStatus online'
              : 'coreStatus offline'
          }
        >
          {on
            ? 'СИСТЕМА АКТИВНА'
            : 'СИСТЕМА ОТКЛЮЧЕНА'}
        </Box>

        <Box
          className={
            on
              ? 'powerToggle active'
              : 'powerToggle'
          }
          onClick={() => act('power')}
        >

          <Box className="toggleLabel">
            ПИТАНИЕ
          </Box>

          <Box className="toggleBody">

            <Box
              className={
                on
                  ? 'toggleSwitch switchOn'
                  : 'toggleSwitch'
              }
            />

          </Box>

        </Box>

      </Box>

      <Box
        className={
          locked
            ? 'accessStatus lockedStatus'
            : 'accessStatus unlockedStatus'
        }
      >

        <Box className="accessLabel">
          ДОСТУП
        </Box>

        <Box className="accessValue">

          <Box className="accessDot" />

          {locked
            ? 'УПРАВЛЕНИЕ ЗАБЛОКИРОВАНО'
            : 'ПОЛНЫЙ ДОСТУП'}

        </Box>

      </Box>

      <Box className="layout">

        <Box className="panel">

          <Box className="panelTitle cleaningTitle">
            УПРАВЛЕНИЕ УБОРКОЙ
          </Box>

          <Button.Checkbox
            fluid
            checked={cleanblood}
            disabled={noaccess}
            onClick={() => act('blood')}
          >
            Убирать кровь
          </Button.Checkbox>

          <Button.Checkbox
            fluid
            checked={autopatrol}
            disabled={noaccess}
            onClick={() => act('autopatrol')}
          >
            Автопатрулирование
          </Button.Checkbox>

          <Button.Checkbox
            fluid
            checked={!remote_disabled}
            disabled={noaccess}
            onClick={() => act('disableremote')}
          >
            Подключение ИИ
          </Button.Checkbox>

        </Box>

        <Box className="log">

          <Box className="panelTitle cleaningTitle">
            ДИАГНОСТИКА
          </Box>

          <Box className="line">
            Питание

            <span className={on ? 'good' : 'bad'}>
              {on
                ? 'НОРМА'
                : 'ОТКЛЮЧЕНО'}
            </span>
          </Box>

          <Box className="line">
            Протоколы безопасности

            <span className={emagged ? 'bad' : 'good'}>
              {emagged
                ? 'НАРУШЕНЫ'
                : 'СТАБИЛЬНЫ'}
            </span>
          </Box>

          <Box className="line">
            Удалённый доступ

            <span className={!remote_disabled ? 'good' : 'bad'}>
              {!remote_disabled
                ? 'РАЗРЕШЁН'
                : 'ЗАПРЕЩЁН'}
            </span>
          </Box>

          <Box className="healthBlock">

            <Box className="healthTitle">
              ЦЕЛОСТНОСТЬ КОРПУСА
            </Box>

            <Box className="healthBar">

              <Box
                className={
                  healthPercent > 60
                    ? 'healthFill healthy'
                    : healthPercent > 30
                      ? 'healthFill damaged'
                      : 'healthFill critical'
                }
                style={{
                  width: `${healthPercent}%`,
                }}
              />

            </Box>

          </Box>

        </Box>

      </Box>

                {!!canhack && (
  <Box className="danger hackBlock">

    <Box className="dangerTitle">
      КРИТИЧЕСКИЙ ДОСТУП
    </Box>

    <Button
      fluid
      color="bad"
      icon="terminal"
      disabled={noaccess}
      onClick={() => act('hack')}
    >
      {emagged
        ? 'Восстановить защиту'
        : 'Взломать систему'}
    </Button>

  </Box>
)}

      {!!painame && (
        <Box className="danger">

          <Box className="dangerTitle">
            ВНЕШНИЙ МОДУЛЬ
          </Box>

          <Button
            fluid
            icon="eject"
            disabled={noaccess}
            onClick={() => act('ejectpai')}
          >
            Извлечь: {painame}
          </Button>

        </Box>
      )}

    </Window.Content>
    </Window>
  );
};

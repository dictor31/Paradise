import { useBackend } from '../backend';
import { Button, Box } from '../components';
import { Window } from '../layouts';

import '../styles/BotSecurity.scss';

export const BotSecurity = () => {
  const { act, data } = useBackend<any>();

  const {
    locked,
    noaccess,
    on,
    autopatrol,
    canhack,
    emagged,
    remote_disabled,
    painame,
    check_id,
    check_weapons,
    check_warrant,
    arrest_mode,
    arrest_declare,
    health,
    maxhealth,
  } = data;

  return (
    <Window width={670} height={760}>
      <Window.Content className="securityBot">

        <Box className="header">

          <Box className="title">
            ОХРАННЫЙ БОТ
          </Box>

          <Box className="sub">
            SECURITY SUPPORT SYSTEM v1.1
          </Box>

        </Box>

        <Box className="authNotice">

          <Box className="authHeader">
            СИСТЕМНОЕ УВЕДОМЛЕНИЕ
          </Box>

          <Box className="authText">

            <Box className="authDot" />

            Для получения полного доступа требуется ID-карта

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
            СТАТУС ДОСТУПА
          </Box>

          <Box className="accessValue">

            <Box className="accessDot" />

            {locked
              ? 'УПРАВЛЕНИЕ ЗАБЛОКИРОВАНО'
              : 'ПОЛНЫЙ ДОСТУП'}

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
            onClick={() => !noaccess && act('power')}
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

        <Box className="layout">

          <Box className="panel">

            <Box className="panelTitle">
              УПРАВЛЕНИЕ
            </Box>

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

            <Button.Checkbox
              fluid
              checked={check_id}
              disabled={noaccess}
              onClick={() => act('authid')}
            >
              Проверка личности
            </Button.Checkbox>

            <Button.Checkbox
              fluid
              checked={check_weapons}
              disabled={noaccess}
              onClick={() => act('authweapon')}
            >
              Проверка оружия
            </Button.Checkbox>

            <Button.Checkbox
              fluid
              checked={check_warrant}
              disabled={noaccess}
              onClick={() => act('authwarrant')}
            >
              Проверка розыска
            </Button.Checkbox>

            <Button.Checkbox
              fluid
              checked={arrest_mode}
              disabled={noaccess}
              onClick={() => act('arrtype')}
            >
              Режим задержания
            </Button.Checkbox>

            <Button.Checkbox
              fluid
              checked={arrest_declare}
              disabled={noaccess}
              onClick={() => act('arrdeclare')}
            >
              Радиооповещение
            </Button.Checkbox>

          </Box>

          <Box className="log">

            <Box className="panelTitle">
              ДИАГНОСТИКА
            </Box>

            <Box className="line">
              Состояние питания
              <span className={on ? 'good' : 'bad'}>
                {on ? 'НОРМА' : 'ОТКЛЮЧЕНО'}
              </span>
            </Box>

            <Box className="line">
              Протоколы безопасности
              <span className={emagged ? 'bad' : 'good'}>
                {emagged ? 'НАРУШЕНЫ' : 'СТАБИЛЬНЫ'}
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
                    health > maxhealth * 0.6
                      ? 'healthFill healthy'
                      : health > maxhealth * 0.3
                        ? 'healthFill damaged'
                        : 'healthFill critical'
                  }
                  style={{
                    width: `${(health / maxhealth) * 100}%`,
                  }}
                />

              </Box>

            </Box>

          </Box>

        </Box>

        {!!canhack && (
          <Box className="danger">

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

            <Button fluid onClick={() => act('ejectpai')}>
              Извлечь: {painame}
            </Button>

          </Box>
        )}

      </Window.Content>
    </Window>
  );
};

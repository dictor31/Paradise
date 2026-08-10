import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

import { BotHeader } from '../components/BotHeader';
import { BotPower } from '../components/BotPower';
import { BotAccess } from '../components/BotAccess';
import { BotHealth } from '../components/BotHealth';
import { BotHack } from '../components/BotHack';
import { BotPanel } from '../components/BotPanel';
import { BotDiagnostic } from '../components/BotDiagnostic';
import { BotButton } from '../components/BotButton';

import '../styles/CommonBot.scss';
import '../styles/MedBot.scss';

type Data = {
  on: boolean;
  locked: boolean;

  health: number;
  maxhealth: number;

  remote_disabled: boolean;

  canhack: boolean;
  emagged: boolean;

  heal_threshold: number;
  injection_amount: number;

  use_beaker: boolean;
  treat_virus: boolean;
  shut_up: boolean;
  declare_crit: boolean;
  auto_patrol: boolean;
  stationary_mode: boolean;

  beaker: boolean;
  beaker_volume: number;
  beaker_max: number;

  noaccess?: boolean;
};

export const MedBot = () => {
  const { act, data } = useBackend<Data>();

  const {
    on,
    locked,

    canhack,
    emagged,

    health,
    maxhealth,
    remote_disabled,

    heal_threshold,
    injection_amount,

    use_beaker,
    treat_virus,
    shut_up,
    declare_crit,
    auto_patrol,
    stationary_mode,

    beaker,
    beaker_volume,
    beaker_max,

    noaccess,
  } = data;

  return (
    <Window width={670} height={760}>
    <Window.Content className="botUI medBot">

      <BotHeader
        title="МЕДИЦИНСКИЙ БОТ"
        subtitle="MEDICAL SUPPORT SYSTEM v1.1"
      />

      <BotPower
        on={on}
        onToggle={() => act('power')}
      />

      <BotAccess
        locked={locked}
      />

      <Box className="layout">

        <BotPanel title="УПРАВЛЕНИЕ ЛЕЧЕНИЕМ">

          <BotButton
            checked={use_beaker}
            disabled={noaccess}
            onClick={() => act('use_beaker')}
          >
            Использовать ёмкость
          </BotButton>

          <BotButton
            checked={treat_virus}
            disabled={noaccess}
            onClick={() => act('virus')}
          >
            Лечение вирусов
          </BotButton>

          <BotButton
            checked={!remote_disabled}
            disabled={noaccess}
            onClick={() => act('disableremote')}
          >
            Подключение ИИ
          </BotButton>

          <BotButton
            checked={!shut_up}
            disabled={noaccess}
            onClick={() => act('togglevoice')}
          >
            Голосовой модуль
          </BotButton>

          <BotButton
            checked={declare_crit}
            disabled={noaccess}
            onClick={() => act('critalerts')}
          >
            Оповещение о критических
          </BotButton>

          <BotButton
            checked={auto_patrol}
            disabled={noaccess}
            onClick={() => act('patrol')}
          >
            Автопатрулирование
          </BotButton>

          <BotButton
            checked={stationary_mode}
            disabled={noaccess}
            onClick={() => act('stationary')}
          >
            Стационарный режим
          </BotButton>

        </BotPanel>

        <BotDiagnostic title="ДИАГНОСТИКА">

          <Box className="line">
            Питание

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
              РЕАГЕНТНЫЙ МОДУЛЬ
            </Box>

            {beaker ? (
              <>
                <Box className="healthBar">

                  <Box
                    className="healthFill healthy"
                    style={{
                      width:
                        `${Math.min(
                          100,
                          (beaker_volume / beaker_max) * 100,
                        )}%`,
                    }}
                  />

                </Box>

                <Box className="good">
                  {beaker_volume}/{beaker_max} ед.
                </Box>

                <Button
                  fluid
                  color="bad"
                  icon="eject"
                  disabled={noaccess}
                  onClick={() => act('eject')}
                >
                  Извлечь ёмкость
                </Button>
              </>
            ) : (
              <Box className="bad">
                ЁМКОСТЬ НЕ УСТАНОВЛЕНА
              </Box>
            )}

          </Box>

          <BotHealth
            health={health}
            maxHealth={maxhealth}
          />

        </BotDiagnostic>

      </Box>

      <Box className="danger">

        <Box className="dangerTitle">
          ПАРАМЕТРЫ ЛЕЧЕНИЯ
        </Box>

        <Box className="adjustRow">

          <Box className="adjustLabel">
            Порог лечения
          </Box>

          <Box className="adjustControls">

            <Button
              disabled={noaccess}
              onClick={() =>
                act('adj_threshold', {
                  value: -5,
                })
              }
            >
              -
            </Button>

            <Box className="adjustValue">
              {heal_threshold}%
            </Box>

            <Button
              disabled={noaccess}
              onClick={() =>
                act('adj_threshold', {
                  value: 5,
                })
              }
            >
              +
            </Button>

          </Box>

        </Box>

        <Box className="adjustRow">

          <Box className="adjustLabel">
            Объём инъекции
          </Box>

          <Box className="adjustControls">

            <Button
              disabled={noaccess}
              onClick={() =>
                act('adj_inject', {
                  value: -5,
                })
              }
            >
              -
            </Button>

            <Box className="adjustValue">
              {injection_amount}
            </Box>

            <Button
              disabled={noaccess}
              onClick={() =>
                act('adj_inject', {
                  value: 5,
                })
              }
            >
              +
            </Button>

          </Box>

        </Box>

      </Box>

      {!!canhack && (
        <BotHack
          emagged={emagged}
          disabled={noaccess}
          onClick={() => act('hack')}
        />
      )}

    </Window.Content>
    </Window>
  );
};

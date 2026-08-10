import { useBackend } from '../backend';
import { Box } from '../components';
import { Window } from '../layouts';

import { BotHeader } from '../components/BotHeader';
import { BotPower } from '../components/BotPower';
import { BotAccess } from '../components/BotAccess';
import { BotPanel } from '../components/BotPanel';
import { BotDiagnostic } from '../components/BotDiagnostic';
import { BotButton } from '../components/BotButton';
import { BotHealth } from '../components/BotHealth';
import { BotCharge } from '../components/BotCharge';
import { BotHack } from '../components/BotHack';
import { BotExternalModule } from '../components/BotExternalModule';

import '../styles/BotCommon.scss';
import '../styles/BotMule.scss';

type MuleBotData = {
  on: boolean;
  locked: boolean;
  noaccess: boolean;

  open: boolean;
  ai: boolean;

  suffix: string;

  mode: number;
  mode_name: Record<string, string>;

  load: string;
  destination: string;

  charge: number;

  auto_return: boolean;
  auto_pickup: boolean;
  auto_report: boolean;

  cell: boolean;

  canhack: boolean;
  emagged: boolean;

  painame: string;
};

export const BotMule = () => {
  const { act, data } = useBackend<MuleBotData>();

  const {
    on,
    locked,
    noaccess,

    open,
    ai,

    suffix,

    mode,
    mode_name,

    load,
    destination,

    charge,

    auto_return,
    auto_pickup,
    auto_report,

    cell,

    canhack,
    emagged,

    painame,
  } = data;

  const modeName =
    mode_name?.[String(mode)] || 'Неизвестное состояние';

  return (
    <Window>

    <Window.Content className="botUI muleBot">

      <BotHeader
        title="ГРУЗОВОЙ БОТ"
        subtitle="M.U.L.E. SYSTEM v5.0"
      />

      <BotPower
        on={on}
        onToggle={() => !noaccess && act('power')}
      />

      <BotAccess
        locked={locked}
      />

      {!open ? (
        <>
          <Box className="layout">

            <BotPanel title="СОСТОЯНИЕ">

              <Box className="muleStatus">
                <Box className="muleStatusLabel">
                  СОСТОЯНИЕ СИСТЕМЫ
                </Box>

                <Box className="muleStatusValue">
                  {modeName}
                </Box>
              </Box>

              <Box className="line">
                <span>Груз</span>

                <span className={load ? 'good' : 'bad'}>
                  {load || 'ОТСУТСТВУЕТ'}
                </span>
              </Box>

              <Box className="line">
                <span>Пункт назначения</span>

                <span className={destination ? 'good' : 'bad'}>
                  {destination || 'ОТСУТСТВУЕТ'}
                </span>
              </Box>

              <BotCharge charge={charge} />

            </BotPanel>

            <BotDiagnostic title="УПРАВЛЕНИЕ">

              <BotButton
                checked={on}
                disabled={noaccess}
                onClick={() => act('power')}
              >
                Включить / выключить
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('stop')}
              >
                Остановиться
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('go')}
              >
                Продолжить движение
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('home')}
              >
                Возврат домой
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('destination')}
              >
                Задать точку назначения
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('setid')}
              >
                Задать ID роботу
              </BotButton>

              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('sethome')}
              >
                Задать домашнюю точку
              </BotButton>

            </BotDiagnostic>

          </Box>

          <Box className="muleOptions">

            <Box className="panelTitle">
              АВТОМАТИЗАЦИЯ
            </Box>

            <BotButton
              checked={auto_return}
              disabled={noaccess}
              onClick={() => act('autoret')}
            >
              Автоматическое возвращение домой
            </BotButton>

            <BotButton
              checked={auto_pickup}
              disabled={noaccess}
              onClick={() => act('autopick')}
            >
              Автоматический подбор ящиков
            </BotButton>

            <BotButton
              checked={auto_report}
              disabled={noaccess}
              onClick={() => act('report')}
            >
              Автоматический отчёт о доставке
            </BotButton>

            {!!load && (
              <BotButton
                checked={false}
                disabled={noaccess}
                onClick={() => act('unload')}
              >
                Разгрузиться
              </BotButton>
            )}

          </Box>

          {!!canhack && (
            <BotHack
              emagged={emagged}
              disabled={noaccess}
              onClick={() => act('hack')}
            />
          )}

          {!!painame && (
            <BotExternalModule
              name={painame}
              disabled={noaccess}
              onEject={() => act('ejectpai')}
            />
          )}
        </>
      ) : (
        <Box className="muleMaintenance">

          <Box className="panelTitle">
            ТЕХНИЧЕСКОЕ ОБСЛУЖИВАНИЕ
          </Box>

          {!ai ? (
            <>
              <Box className="muleNotice">
                ПАНЕЛЬ ТЕХНИЧЕСКОГО ОБСЛУЖИВАНИЯ ОТКРЫТА
              </Box>

              <Box className="line">
                <span>Батарея</span>

                <span className={cell ? 'good' : 'bad'}>
                  {cell ? 'УСТАНОВЛЕНА' : 'ОТСУТСТВУЕТ'}
                </span>
              </Box>

              <Box className="muleMaintenanceControls">

                {cell ? (
                  <BotButton
                    checked
                    disabled={noaccess}
                    onClick={() => act('cellremove')}
                  >
                    Извлечь батарею
                  </BotButton>
                ) : (
                  <BotButton
                    checked={false}
                    disabled={noaccess}
                    onClick={() => act('cellinsert')}
                  >
                    Установить батарею
                  </BotButton>
                )}

                <BotButton
                  checked={false}
                  disabled={noaccess}
                  onClick={() => act('wires')}
                >
                  Открыть блок проводов
                </BotButton>

              </Box>
            </>
          ) : (
            <Box className="muleNotice">
              РОБОТ В РЕЖИМЕ ТЕХНИЧЕСКОГО ОБСЛУЖИВАНИЯ.
              УПРАВЛЕНИЕ ПОВЕДЕНИЕМ ЗАБЛОКИРОВАНО.
            </Box>
          )}

        </Box>
      )}

    </Window.Content>
      </Window>

  );
};

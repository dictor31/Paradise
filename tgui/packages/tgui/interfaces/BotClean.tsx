import { useBackend } from '../backend';
import { Box } from '../components';
import { Window } from '../layouts';

import { BotHeader } from '../components/BotHeader';
import { BotPower } from '../components/BotPower';
import { BotAccess } from '../components/BotAccess';
import { BotHealth } from '../components/BotHealth';
import { BotHack } from '../components/BotHack';
import { BotPanel } from '../components/BotPanel';
import { BotDiagnostic } from '../components/BotDiagnostic';
import { BotExternalModule } from '../components/BotExternalModule';
import { BotButton } from '../components/BotButton';

import '../styles/CommonBot.scss';
import '../styles/CleanBot.scss';

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

  return (
    <Window width={670} height={760}>
      <Window.Content className="botUI cleanBot">

        <BotHeader
          title="УБОРОЧНЫЙ БОТ"
          subtitle="CLEANING SUPPORT SYSTEM v1.1"
        />

        <BotPower
          on={on}
          onToggle={() => act('power')}
        />

        <BotAccess
          locked={locked}
        />

        <Box className="layout">

          <BotPanel title="УПРАВЛЕНИЕ УБОРКОЙ">

            <BotButton
              checked={cleanblood}
              disabled={noaccess}
              onClick={() => act('blood')}
            >
              Убирать кровь
            </BotButton>

            <BotButton
              checked={autopatrol}
              disabled={noaccess}
              onClick={() => act('autopatrol')}
            >
              Автопатрулирование
            </BotButton>

            <BotButton
              checked={!remote_disabled}
              disabled={noaccess}
              onClick={() => act('disableremote')}
            >
              Подключение ИИ
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
                {!remote_disabled ? 'РАЗРЕШЁН' : 'ЗАПРЕЩЁН'}
              </span>
            </Box>

            <BotHealth
              health={health}
              maxHealth={maxhealth}
            />

          </BotDiagnostic>

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

      </Window.Content>
    </Window>
  );
};

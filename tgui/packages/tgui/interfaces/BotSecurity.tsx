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
import '../styles/SecurityBot.scss';

type SecurityBotData = {
  locked: boolean;
  noaccess: boolean;
  on: boolean;
  autopatrol: boolean;
  canhack: boolean;
  emagged: boolean;
  remote_disabled: boolean;
  painame: string;
  check_id: boolean;
  check_weapons: boolean;
  check_warrant: boolean;
  arrest_mode: boolean;
  arrest_declare: boolean;
  health: number;
  maxhealth: number;
};

export const BotSecurity = () => {
  const { act, data } = useBackend<SecurityBotData>();

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
      <Window.Content className="botUI securityBot">

        <BotHeader
          title="ОХРАННЫЙ БОТ"
          subtitle="SECURITY SUPPORT SYSTEM v1.1"
        />

        <BotPower
          on={on}
          onToggle={() => !noaccess && act('power')}
        />

        <BotAccess
          locked={locked}
        />

        <Box className="layout">

          <BotPanel title="УПРАВЛЕНИЕ">

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

            <BotButton
              checked={check_id}
              disabled={noaccess}
              onClick={() => act('authid')}
            >
              Проверка личности
            </BotButton>

            <BotButton
              checked={check_weapons}
              disabled={noaccess}
              onClick={() => act('authweapon')}
            >
              Проверка оружия
            </BotButton>

            <BotButton
              checked={check_warrant}
              disabled={noaccess}
              onClick={() => act('authwarrant')}
            >
              Проверка розыска
            </BotButton>

            <BotButton
              checked={arrest_mode}
              disabled={noaccess}
              onClick={() => act('arrtype')}
            >
              Режим задержания
            </BotButton>

            <BotButton
              checked={arrest_declare}
              disabled={noaccess}
              onClick={() => act('arrdeclare')}
            >
              Радиооповещение
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

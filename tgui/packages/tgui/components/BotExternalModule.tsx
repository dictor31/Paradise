import { Button, Box } from '../components';

type Props = {
  name: string;
  disabled?: boolean;
  onEject: () => void;
};

export const BotExternalModule = ({
  name,
  disabled = false,
  onEject,
}: Props) => {
  return (
    <Box className="danger">

      <Box className="dangerTitle">
        ВНЕШНИЙ МОДУЛЬ
      </Box>

      <Button
        fluid
        icon="eject"
        disabled={disabled}
        onClick={onEject}
      >
        Извлечь: {name}
      </Button>

    </Box>
  );
};

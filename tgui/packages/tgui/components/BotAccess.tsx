import { Box } from './Box';

type Props = {
  locked: boolean;
};

export const BotAccess = ({ locked }: Props) => {
  return (
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
  );
};

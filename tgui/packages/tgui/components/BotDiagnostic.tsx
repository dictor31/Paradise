import type { ReactNode } from 'react';
import { Box } from '../components';

type Props = {
  title: string;
  children: ReactNode;
};

export const BotDiagnostic = ({ title, children }: Props) => {
  return (
    <Box className="log">

      <Box className="panelTitle">
        {title}
      </Box>

      {children}

    </Box>
  );
};

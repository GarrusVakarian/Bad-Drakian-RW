import locale from './ChessBoard.i18n.en';
import { ChessBoardView } from './ChessBoardView';

export const ChessBoard = () => {
  return <ChessBoardView locale={locale} />;
};

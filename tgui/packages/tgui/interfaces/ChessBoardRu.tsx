import locale from './ChessBoard.i18n.ru';
import { ChessBoardView } from './ChessBoardView';

export const ChessBoardRu = () => {
  return <ChessBoardView locale={locale} />;
};

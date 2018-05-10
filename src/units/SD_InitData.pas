unit SD_InitData;

interface
const
  Tolerance = 5; // Кол-во пискелей, на которые юзеру можно "промахнуться"
  NearFigure = 40; // Количество пикселей, при котором идет "присоединение" фигуры;
  step_round = 20;
  Default_LineSVG_Width = 2;
  Font_Size = 8;

resourcestring
  rsNewFileDlg = 'Вы уверены? Все несохраненные данные будут удалены. Продолжить?';
  rsNewFile = 'Новый файл';
  rsExitDlg = 'Вы внесли изменения.. А не хотите ли Вы сохраниться перед тем, как выйти?';
  rsInvalidFile = 'Вы пытаетесь открыть какой-то непонятный файл. Пожалуйста, используйте только файлы, созданные этой программой!';

resourcestring
  rsHelpHowIsSD_Caption = 'Что такое синтаксическая диаграмма?';
  rsHelp_Caption = 'Помощь';
const
  rsHelpHowIsSD_ResName = 'help1';
  rsHelp_ResName = 'help2';

implementation



end.

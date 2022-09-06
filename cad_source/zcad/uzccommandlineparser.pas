{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzcCommandLineParser;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzbCommandLineParser;

var
  CommandLineParser:TCommandLineParser;

  NOSPLASHHDL,              //опция nosplash - не показывать сплэш
  UPDATEPOHDL,              //опция updatepo - актуализация файлов локализации, необходима для команды updatepo
  NOLOADLAYOUTHDL,          //опция noloadlayout - запуск без загрузки начального состояния раскладки окон
  LOGFILEHDL,               //опция logfile - указание лог фала, требует аргумент(ы) имя файла
  NOTCHECKUNIQUEINSTANCEHDL,//опция noloadlayout - запуск без загрузки начального состояния раскладки окон
  LEAMHDL                   //опция leam -(Log Enable All Modules) разрешение записи в лог всех модулей
  :TOptionHandle;

implementation

initialization
  CommandLineParser.Init;
  NOSPLASHHDL:=CommandLineParser.RegisterArgument('nosplash',AT_Flag);
  UPDATEPOHDL:=CommandLineParser.RegisterArgument('updatepo',AT_Flag);
  NOLOADLAYOUTHDL:=CommandLineParser.RegisterArgument('noloadlayout',AT_Flag);
  LOGFILEHDL:=CommandLineParser.RegisterArgument('logfile',AT_WithOperands);
  NOTCHECKUNIQUEINSTANCEHDL:=CommandLineParser.RegisterArgument('notcheckuniqueinstance',AT_Flag);
  LEAMHDL:=CommandLineParser.RegisterArgument('leam',AT_Flag);
  CommandLineParser.ParseCommandLine;
finalization
  CommandLineParser.Done;
end.


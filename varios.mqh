//+------------------------------------------------------------------+
//|                                                       varios.mqh |
//|                      Copyright 2022, Brickell Financial Advisors |
//|                            https://brickellfinancialadvisors.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Brickell Financial Advisors"
#property link      "https://brickellfinancialadvisors.com"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include "C_FiltroRangoTiempo.mqh"

C_FiltroRangoTiempo filtroMercado;


struct posicionPropia
  {
   string            simbolo;
   ulong             magico;
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VerificarSiMercadoAbierto(const string _simbolo, bool &_salida1)
  {

   const ENUM_DAY_OF_WEEK _diaSemana = DiaSemana();

   datetime from, to;

   MqlDateTime _time_from, _time_to;

   uint session_index = 0;

   while(true)
     {

      if(!SymbolInfoSessionQuote(_simbolo, _diaSemana, session_index, from, to))
        {

         if(_LastError == 4307)
           {
            ResetLastError();
           }

         return true;

        }

      TimeToStruct(from, _time_from);
      TimeToStruct(to, _time_to);

      filtroMercado.set_Time_inicio(uchar(_time_from.hour), uchar(_time_from.min));

      if((from < to) && (_time_to.hour == 0) && (_time_to.min == 0)) //puede ser desde las 23 hasta las 00
        {
         filtroMercado.set_Time_fin(23, 59);
        }
      else
        {
         filtroMercado.set_Time_fin(uchar(_time_to.hour), uchar(_time_to.min));
        }

      if(!filtroMercado.EstaEntreRango(TimeCurrent(), _salida1))
         return false;

      if(_salida1)
         return true;

      session_index++;

     }

   return true;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool detectarError()
  {

   if(_LastError != 0)
     {

      Print("Error: " + IntegerToString(_LastError) + ", " + __FUNCTION__);

      if(MQLInfoInteger(MQL_TESTER))
         ExpertRemove();
      else
         ResetLastError();

      return true;

     }

   return false;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool fechaVencida()
  {

   if(TimeCurrent() >= D'2023.03.01')
      return true;

   return false;
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarTodasLasPosiciones(const ulong _deslizamiento, string &_mensaje)
  {

   _mensaje = "";

   bool _salida = true;

   CTrade _orden;

   _orden.SetDeviationInPoints(_deslizamiento);

   CPositionInfo positionInfo;

   for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
     {

      if(!positionInfo.SelectByIndex(_cont))
        {

         if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
           {
            ResetLastError();
            continue;
           }

         Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

         _salida = false;

         continue;
        }

      positionInfo.StoreState();

      if(!_orden.PositionClose(
            positionInfo.Ticket(),
            _deslizamiento
         ))
        {

         _salida = false;

         Print("*/");
         Print("!PositionClose " + IntegerToString(_LastError));
         _orden.PrintResult();
         _orden.PrintRequest();
         Print("*/");

         if(_LastError == ERR_TRADE_SEND_FAILED)
           {
            ResetLastError();
            continue;
           }

         if(!MQLInfoInteger(MQL_TESTER))
            ResetLastError();

        }

     }

   return _salida;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarTodasLasPosicionesCondicionada(
   posicionPropia &_posicion[],
   string &_mensaje,
   const ulong _deslizamiento
)
  {

   if(ArraySize(_posicion) == 0)
     {
      return CerrarTodasLasPosiciones(_deslizamiento, _mensaje);
     }

   _mensaje = "";

   bool _salida = true;

   CTrade _orden;
   _orden.SetAsyncMode(true);
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.SetMarginMode();

   CPositionInfo positionInfo;

   bool _salidaMercado;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      if(!VerificarSiMercadoAbierto(_posicion[i].simbolo, _salidaMercado))
        {

         _mensaje += "Fallo en !VerificarSiMercadoAbierto.";

         _salida = false;
         continue;
        }

      if(!_salidaMercado)
        {

         _mensaje += "No puedo cerrar posiciones en " +
                     _posicion[i].simbolo +
                     ". Mercado cerrado."
                     ;

         _salida = false;
         continue;

        }

      _orden.SetTypeFillingBySymbol(_posicion[i].simbolo);
      _orden.SetExpertMagicNumber(_posicion[i].magico);

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               ResetLastError();
               continue;
              }

            Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

            _salida = false;

            continue;
           }

         positionInfo.StoreState();

         if(positionInfo.Symbol() != _posicion[i].simbolo)
            continue;

         if(positionInfo.Magic() != _posicion[i].magico)
            continue;

         if(!_orden.PositionClose(
               positionInfo.Ticket(),
               _deslizamiento
            ))
           {

            _salida = false;

            Print("*/");
            Print("!PositionClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();
            Print("*/");

            if(_LastError == ERR_TRADE_SEND_FAILED)
              {
               ResetLastError();
               continue;
              }

            if(!MQLInfoInteger(MQL_TESTER))
               ResetLastError();

           }

        }

     }

   return _salida;

  }








//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK DiaSemana()
  {

   MqlDateTime dt_struct ;
   TimeCurrent(dt_struct);

   switch(dt_struct.day_of_week)
     {
      case 0:
         return SUNDAY;
      case 1:
         return MONDAY;
      case 2:
         return TUESDAY;
      case 3:
         return WEDNESDAY;
      case 4:
         return THURSDAY;
      case 5:
         return FRIDAY;
      default:
         return SATURDAY;
     }

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VerificarPreEstado(const string _simbolo)
  {

   string _mensaje = "";

   if(!tradingHabilitado(_mensaje))
     {
      Print(_mensaje);
      return false;
     }

   bool _salidaMercado;

   if(!VerificarSiMercadoAbierto(_simbolo, _salidaMercado))
     {
      Print("Fallo !VerificarSiMercadoAbierto.");
      return false;
     }

   if(!_salidaMercado)
     {
      Print("Mercado cerrado.");
      return false;
     }

   return true;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tradingHabilitado(string &_mensaje)
  {

   _mensaje = "";

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      _mensaje = "El trading automatico esta deshabilitado en el metatrader.";
      return false;
     }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      _mensaje = "El trading automático está deshabilitado en el experto.";
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+

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

   _salida1 = false;

   const ENUM_DAY_OF_WEEK _diaSemana = DiaSemana();

   datetime from, to;

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

      if((from == D'1970.01.01 00:00:00') && (to == D'1970.01.02 00:00:00'))
        {
         _salida1 = true;
         return true;
        }

      MqlDateTime _time_from, _time_to;

      TimeToStruct(from, _time_from);
      TimeToStruct(to, _time_to);

      C_FiltroRangoTiempo filtroMercado;

      filtroMercado.set_Time_inicio(uchar(_time_from.hour), uchar(_time_from.min));

      if((from < to) && (_time_to.hour == 0) && (_time_to.min == 0)) //puede ser desde las 23 hasta las 00
        {
         filtroMercado.set_Time_fin(0, 0);
        }
      else
        {
         filtroMercado.set_Time_fin(uchar(_time_to.hour), uchar(_time_to.min), 59);
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

   if(TimeCurrent() >= D'2023.04.01')
      return true;

   return false;
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
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitHistorico(
   const posicionPropia &_posicion[],
   const datetime from_date, // desde el principio
   const datetime to_date, // hasta el momento actual
   double & _profitTotal
)
  {

   _profitTotal = 0;

   double _profit;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      if(!ProfitHistorico(
            _posicion[i].simbolo,
            _posicion[i].magico,
            from_date, // desde el principio
            to_date, // hasta el momento actual
            _profit
         ))
         return false;

      _profitTotal += _profit;

     }

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitHistorico(
   const string _simbolo,
   const long _magico,
   const datetime from_date,         // desde el principio
   const datetime to_date, // hasta el momento actual
   double & _profit
)
  {

   _profit = 0;

   if(!HistorySelect(from_date - 1, to_date))
     {
      Print("!HistorySelect");
      return false;
     }

   bool _salida = true;

   CDealInfo DealInfo;

   const int deals = HistoryDealsTotal();

   for(int i = 0; i < deals; i++)
     {

      if(!DealInfo.SelectByIndex(i))
        {
         _salida = false;
         continue;
        }

      if(DealInfo.Entry() != DEAL_ENTRY_OUT)
         continue;

      if(DealInfo.Symbol() != _simbolo)
         continue;

      if(DealInfo.Magic() != _magico)
         continue;

      _profit += DealInfo.Profit();

     }

   return _salida;

  }


//+------------------------------------------------------------------+
//| Despues de cierta cantidad de puntos se activa breakEven         |
//+------------------------------------------------------------------+
bool breakEvenPuntos(
   const string _simboloString,
   const long _magico,
   const bool _activado,
   const int _puntosActivacion,
   const int _puntosAdicionales
)
  {

   if(!_activado)
      return true;

//Print("");

   CSymbolInfo _simbolo;

   if(!_simbolo.Name(_simboloString))
      return false;

   bool _salida = true;

   CPositionInfo positionInfo;

   double _sl_propuesto = -1;

   double _sl_actual = -1;

   const double _puntosActivacion2 = _puntosActivacion * _simbolo.Point();

   const double _puntosAdicionales2 = _puntosAdicionales * _simbolo.Point();

   CTrade _orden;

   _orden.SetExpertMagicNumber(_magico);
   _orden.SetMarginMode();
   _orden.SetTypeFillingBySymbol(_simbolo.Name());
//_orden.SetDeviationInPoints(deslizamiento); // al parecer no es necesario
   _orden.LogLevel(LOG_LEVEL_ALL);

   _simbolo.RefreshRates();

   for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
     {

      if(!positionInfo.SelectByIndex(_cont))
        {

         Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

         if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
           {
            ResetLastError();
            continue;
           }

         _salida = false;

         continue;

        }

      positionInfo.StoreState();

      if(positionInfo.Symbol() != _simbolo.Name())
         continue;

      if(positionInfo.Magic() != _magico)
         continue;

      _sl_actual = _simbolo.NormalizePrice(positionInfo.StopLoss());

      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
        {

         if(_sl_actual >= positionInfo.PriceOpen())
            continue;

         if(!((_simbolo.Bid() - positionInfo.PriceOpen()) >= _puntosActivacion2))
            continue;

         _sl_propuesto = _simbolo.NormalizePrice(
                            positionInfo.PriceOpen() + _puntosAdicionales2
                         );

         if((_simbolo.Bid() - _sl_propuesto) <= (_simbolo.StopsLevel() * _simbolo.Point()))
           {

            Print(
               __FUNCTION__ +
               ", (Bid() - sl) <= StopsLevel"
            );

            _salida = false;

            continue;

           }

        }

      if(positionInfo.PositionType() == POSITION_TYPE_SELL)
        {

         if(_sl_actual <= positionInfo.PriceOpen())
            continue;

         if(!((positionInfo.PriceOpen() - _simbolo.Ask()) >= _puntosActivacion2))
            continue;

         _sl_propuesto = _simbolo.NormalizePrice(
                            positionInfo.PriceOpen() - _puntosAdicionales2
                         );

         if((_sl_propuesto - _simbolo.Ask()) <= (_simbolo.StopsLevel() * _simbolo.Point()))
           {

            Print(
               __FUNCTION__ +
               ", (sl - Ask) <= StopsLevel"
            );

            _salida = false;

            continue;

           }

        }

      if(_sl_actual == _sl_propuesto)
         continue;

      if(!VerificarPreEstado(_simbolo.Name()))
        {
         _salida = false;

         continue;
        }

      Print("");
      if(!_orden.PositionModify(
            positionInfo.Ticket(),
            _sl_propuesto,
            positionInfo.TakeProfit()
         ))
        {
         Print("!_orden.PositionModify");
         Print("Bid: " + DoubleToString(_simbolo.Bid(), _simbolo.Digits()));
         Print("Ask: " + DoubleToString(_simbolo.Ask(), _simbolo.Digits()));
         Print(EnumToString(positionInfo.PositionType()));
         Print("open: " + DoubleToString(positionInfo.PriceOpen(), _simbolo.Digits()));
         _orden.PrintRequest();
         _orden.PrintResult();

         _salida = false;
        }

      Print("");

     }

//Print("");

   return _salida;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarPosicionesPositivas(
   const posicionPropia &_posicion[],
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   bool _salida = true;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      if(!CerrarPosicionesPositivas(
            _posicion[i].simbolo,
            _posicion[i].magico,
            _deslizamiento,
            _asincronico
         ))
        {
         _salida = false;
        }

     }

   return _salida;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarPosicionesPositivas(
   const string _simbolo,
   const ulong _magico,
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   bool _salida;

   CPositionInfo positionInfo;

   bool _salidaMercado;

   uint _cantPosiciones;

   CTrade _orden;
   _orden.SetAsyncMode(_asincronico);
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.SetMarginMode();
   _orden.LogLevel(LOG_LEVEL_ALL);
   _orden.SetTypeFillingBySymbol(_simbolo);
   _orden.SetExpertMagicNumber(_magico);

   while(true)
     {

      Print("\nVoy a intentar cerrar posiciones positivas.");

      _cantPosiciones = 0;

      _salida = true;

      if(!VerificarSiMercadoAbierto(_simbolo, _salidaMercado))
        {
         Print("Fallo en !VerificarSiMercadoAbierto.");
         return false;
        }

      if(!_salidaMercado)
        {

         Print("No puedo cerrar posiciones en " +
               _simbolo +
               ". Mercado cerrado."
              );

         return false;

        }

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               Print("Posicion " + IntegerToString(_cont) + " no encontrada.");
              }
            else
              {
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));
              }

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            _salida = false;

            break;

           }

         positionInfo.StoreState();

         if(positionInfo.Symbol() != _simbolo)
            continue;

         if(positionInfo.Magic() != _magico)
            continue;

         if(positionInfo.Profit() <= 0)
            continue;

         if(!_orden.PositionClose(
               positionInfo.Ticket(),
               _deslizamiento
            ))
           {

            Print("----");
            Print("!PositionClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();
            Print("Error: " + IntegerToString(_LastError));
            Print("----");

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            _salida = false;

            break;

           }

         _cantPosiciones++;

        }


      if(_salida)
        {
         Print("Pude cerrar " + IntegerToString(_cantPosiciones) + " las posiciones positivas.");
         return true;
        }

      Print("Voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong ContarPosiciones(
   const string _simbolo,
   const ulong _magico
)
  {

   bool _salida;

   CPositionInfo positionInfo;

   ulong _contPosiciones;

   while(true)
     {

      //Print("\nVoy a intentar contar posiciones.");

      _contPosiciones = 0;

      _salida = true;

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               Print("No encontre posicion " + IntegerToString(_cont));
              }
            else
              {
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));
              }

            ResetLastError();

            _salida = false;

            break;

           }

         positionInfo.StoreState();

         if(positionInfo.Symbol() != _simbolo)
            continue;

         if(positionInfo.Magic() != _magico)
            continue;

         _contPosiciones++;

        }

      if(_salida)
        {
         //Print(IntegerToString(_contPosiciones) + " posiciones abiertas.");
         return _contPosiciones;
        }

      Print("Tuve error, voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong ContarPendientes(
   const string _simbolo,
   const ulong _magico
)
  {

   COrderInfo _orderInfo;

   ulong _contOrdenes;

   bool _salida;

   while(true)
     {

      _contOrdenes = 0;

      Print("\nVoy a intentar contar ordenes pendientes.");

      _salida = true;

      for(int _cont = (OrdersTotal() - 1); _cont >= 0; _cont--)
        {

         if(!_orderInfo.SelectByIndex(_cont))
           {

            _salida = false;

            if(_LastError == ERR_TRADE_ORDER_NOT_FOUND)
               Print("Orden " + IntegerToString(_cont) + " no encontrada.");
            else
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            break;

           }

         _orderInfo.StoreState();

         if(_orderInfo.Symbol() != _simbolo)
            continue;

         if(_orderInfo.Magic() != _magico)
            continue;

         _contOrdenes++;

        }

      if(_salida)
        {
         Print(IntegerToString(_contOrdenes) + " ordenes pendientes puestas.");
         return _contOrdenes;
        }

      Print("Error, voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong ContarPosiciones(const posicionPropia &_posicion[])
  {

   ulong _cantPosiciones = 0;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      _cantPosiciones = ContarPosiciones(_posicion[i].simbolo, _posicion[i].magico);

     }

   return _cantPosiciones;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalLotes(
   const posicionPropia & _posicion[],
   const ENUM_POSITION_TYPE _tipoPosicion
)
  {
   double totalLote = 0;

   for(int i = (ArraySize(_posicion) - 1); i <= 0; i--)
     {

      totalLote += TotalLotes(
                      _posicion[i].simbolo,
                      _posicion[i].magico,
                      _tipoPosicion
                   );

     }

   return totalLote;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalLotes(
   const string _simbolo,
   const ulong _magico,
   const ENUM_POSITION_TYPE _tipoPosicion
)
  {

   bool _salida;

   CPositionInfo positionInfo;

   double _cantLotes;

   while(true)
     {

      //Print("\nVoy a intentar contar lotes.");

      _cantLotes = 0;

      _salida = true;

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               Print("No encontre posicion " + IntegerToString(_cont));
              }
            else
              {
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));
              }

            ResetLastError();

            _salida = false;

            break;

           }

         positionInfo.StoreState();

         if(positionInfo.Symbol() != _simbolo)
            continue;

         if(positionInfo.Magic() != _magico)
            continue;

         if(positionInfo.PositionType() != _tipoPosicion)
            continue;

         _cantLotes += positionInfo.Volume();

        }

      if(_salida)
        {

         // Print(
         //  IntegerToString(_cantLotes) + " lotes para " + EnumToString(_tipoPosicion)
         // );

         return _cantLotes;

        }

      Print("Tuve error, voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong ContarPendientes(const posicionPropia &_posicion[])
  {

   ulong _cantPendientes = 0;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      _cantPendientes = ContarPendientes(_posicion[i].simbolo, _posicion[i].magico);

     }

   return _cantPendientes;

  }


//+------------------------------------------------------------------+
//| detecta si se disparó pendiente                                  |
//+------------------------------------------------------------------+
bool EjecutoPendiente(
   const MqlTradeTransaction& trans
)
  {

   if(trans.type != TRADE_TRANSACTION_HISTORY_ADD)
      return false;

   if(trans.order_state != ORDER_STATE_FILLED)
      return false;

   return true;

  }


//+------------------------------------------------------------------+
//| detecta si ejecutó stopLoss                                      |
//+------------------------------------------------------------------+
bool DisparoSL(const MqlTradeTransaction& trans)
  {
   if(trans.type != TRADE_TRANSACTION_HISTORY_ADD)
      return false;

   if(trans.price_sl != 0)
      return false;

   return true;

  }



//+------------------------------------------------------------------+
//| Establece si se disparó buy stop                                |
//+------------------------------------------------------------------+
bool BuyStop(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& request
)
  {


   if(

// Primer llamado
      (
         (trans.type == TRADE_TRANSACTION_DEAL_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY) &&
         (trans.order_state == ORDER_STATE_STARTED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Segundo llamado
      (
         (trans.type == TRADE_TRANSACTION_ORDER_DELETE) &&
         (trans.order_type == ORDER_TYPE_BUY_STOP) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Tercer llamado
      (
         (trans.type == TRADE_TRANSACTION_HISTORY_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY_STOP) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

   )
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellStop(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& request
)
  {

   if(

// Primer llamado
      (
         (trans.type == TRADE_TRANSACTION_DEAL_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY) &&
         (trans.order_state == ORDER_STATE_STARTED) &&
         (trans.deal_type == DEAL_TYPE_SELL) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Segundo llamado
      (
         (trans.type == TRADE_TRANSACTION_ORDER_DELETE) &&
         (trans.order_type == ORDER_TYPE_SELL_STOP) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Tercer llamado
      (
         (trans.type == TRADE_TRANSACTION_HISTORY_ADD) &&
         (trans.order_type == ORDER_TYPE_SELL_STOP) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

   )
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//| Establece si se disparó buy limit                                |
//+------------------------------------------------------------------+
bool SellLimit(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& request
)
  {

   if(

// Primer llamado
      (
         (trans.type == TRADE_TRANSACTION_DEAL_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY) &&
         (trans.order_state == ORDER_STATE_STARTED) &&
         (trans.deal_type == DEAL_TYPE_SELL) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// segundo llamado
      (
         (trans.type == TRADE_TRANSACTION_ORDER_DELETE) &&
         (trans.order_type == ORDER_TYPE_SELL_LIMIT) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Tercer llamado
      (
         (trans.type == TRADE_TRANSACTION_HISTORY_ADD) &&
         (trans.order_type == ORDER_TYPE_SELL_LIMIT) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )
   )

     {
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//| Establece si se disparó buy limit                                |
//+------------------------------------------------------------------+
bool BuyLimit(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& request
)
  {


   return false;

   if(
      (
         (trans.type == TRADE_TRANSACTION_DEAL_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY) &&
         (trans.order_state == ORDER_STATE_STARTED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Segundo llamado
      (
         (trans.type == TRADE_TRANSACTION_ORDER_DELETE) &&
         (trans.order_type == ORDER_TYPE_BUY_LIMIT) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )

      ||

// Tercer llamado
      (
         (trans.type == TRADE_TRANSACTION_HISTORY_ADD) &&
         (trans.order_type == ORDER_TYPE_BUY_LIMIT) &&
         (trans.order_state == ORDER_STATE_FILLED) &&
         (trans.deal_type == DEAL_TYPE_BUY) &&
         (trans.time_type == ORDER_TIME_GTC) &&
         (request.type == ORDER_TYPE_BUY) &&
         (request.type_filling == ORDER_FILLING_FOK) &&
         (request.type_time == ORDER_TIME_GTC)
      )
   )

     {
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double profitFlotante(const posicionPropia &_posicion[])
  {

   double _profitTotal = 0;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      _profitTotal += profitFlotante(_posicion[i].simbolo, _posicion[i].magico);

     }

   return _profitTotal;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarPosiciones(
   const posicionPropia &_posicion[],
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   bool _salida = true;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      if(!CerrarPosiciones(
            _posicion[i].simbolo,
            _posicion[i].magico,
            _deslizamiento,
            _asincronico
         ))
        {
         _salida = false;
        }

     }

   return _salida;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarPosiciones(
   const string _simbolo,
   const ulong _magico,
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   bool _salida;

   CPositionInfo positionInfo;

   bool _salidaMercado;

   CTrade _orden;
   _orden.SetAsyncMode(_asincronico);
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.SetMarginMode();
   _orden.LogLevel(LOG_LEVEL_ALL);
   _orden.SetTypeFillingBySymbol(_simbolo);
   _orden.SetExpertMagicNumber(_magico);

   while(true)
     {

      Print("\nVoy a intentar cerrar posiciones.");

      _salida = true;

      if(!VerificarSiMercadoAbierto(_simbolo, _salidaMercado))
        {
         Print("Fallo en !VerificarSiMercadoAbierto.");
         return false;
        }

      if(!_salidaMercado)
        {

         Print("No puedo cerrar posiciones en " +
               _simbolo +
               ". Mercado cerrado."
              );

         return false;

        }

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               Print("Posicion " + IntegerToString(_cont) + " no encontrada.");
              }
            else
              {
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));
              }

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            _salida = false;

            break;

           }

         positionInfo.StoreState();

         if(positionInfo.Symbol() != _simbolo)
            continue;

         if(positionInfo.Magic() != _magico)
            continue;

         if(!_orden.PositionClose(
               positionInfo.Ticket(),
               _deslizamiento
            ))
           {

            Print("----");
            Print("!PositionClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();

            if(_LastError == ERR_TRADE_SEND_FAILED)
              {
               Print("ERR_TRADE_SEND_FAILED");
              }
            else
              {
               Print("Error: " + IntegerToString(_LastError));
              }

            Print("----");

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            _salida = false;

            break;

           }

        }

      if(_salida)
        {
         Print("Pude cerrar todas las posiciones.");
         return true;
        }

      Print("Voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BorrarPendientes(
   posicionPropia &_posicion[],
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   bool _salida = true;

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {

      if(!BorrarPendientes(
            _posicion[i].simbolo,
            _posicion[i].magico,
            _deslizamiento,
            _asincronico
         ))
        {
         _salida = false;
        }

     }

   return _salida;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BorrarPendientes(
   const string _simbolo,
   const ulong _magico,
   const ulong _deslizamiento,
   const bool _asincronico
)
  {

   CTrade _orden;
   _orden.SetAsyncMode(_asincronico);
   _orden.SetMarginMode();
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.LogLevel(LOG_LEVEL_ALL);
   _orden.SetTypeFillingBySymbol(_simbolo);
   _orden.SetExpertMagicNumber(_magico);

   COrderInfo _orderInfo;

   bool _salidaMercado;

   bool _salida;

   while(true)
     {

      Print("\nVoy a intentar borrar ordenes pendientes.");

      if(!VerificarSiMercadoAbierto(_simbolo, _salidaMercado))
        {
         Print("Fallo en !VerificarSiMercadoAbierto.");
         return false;
        }

      if(!_salidaMercado)
        {

         Print(
            "No puedo Borrar Pendientes en " +
            _simbolo +
            ". Mercado cerrado."
         );

         return false;

        }

      _salida = true;

      for(int _cont = (OrdersTotal() - 1); _cont >= 0; _cont--)
        {

         if(!_orderInfo.SelectByIndex(_cont))
           {

            _salida = false;

            if(_LastError == ERR_TRADE_ORDER_NOT_FOUND)
               Print("Orden " + IntegerToString(_cont) + " no encontrada.");
            else
               Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            break;

           }

         _orderInfo.StoreState();

         if(_orderInfo.Symbol() != _simbolo)
            continue;

         if(_orderInfo.Magic() != _magico)
            continue;

         if(!_orden.OrderDelete(_orderInfo.Ticket()))
           {

            _salida = false;

            Print("----");
            Print("!_ordenClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();
            Print("Error: " + IntegerToString(_LastError));
            Print("----");

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            break;

           }

        }

      if(_salida)
        {
         Print("Pude borrar todas las ordenes.\n");
         return true;
        }

      Print("Voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double profitFlotante(const string _simbolo, const long _magico)
  {

   bool _salida; // Guarda si la función ha corrido bien o no.

   double _profit;

   CPositionInfo positionInfo;

   while(true)
     {

      //Print("Voy a intentar calcular profitFlotante...");

      _salida = true;

      _profit = 0;

      for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
        {

         if(!positionInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
              {
               Print("ERR_TRADE_POSITION_NOT_FOUND, " + __FUNCTION__);
              }
            else
              {
               Print("Error "+IntegerToString(_LastError) + ", " + __FUNCTION__);
              }

            _salida = false;

            continue;

           }

         if(positionInfo.Symbol() != _simbolo)
            continue;

         if(positionInfo.Magic() != _magico)
            continue;

         positionInfo.StoreState();

         _profit += positionInfo.Profit();

        }

      if(_salida)
        {
         //Print("Pude calcular profit flotante.");
         return _profit;
        }
      else
        {
         //Print("No pude calcular profit flotante. Coy a volver a intentar.");
        }

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EnumTimeFrameToString(const ENUM_TIMEFRAMES _periodo)
  {
   struct p_1
     {
      int            segundos;
      string         frecuencia;
     };

   p_1 p_[21];

   p_[0].segundos=PeriodSeconds(PERIOD_MN1);
   p_[1].segundos=PeriodSeconds(PERIOD_W1);
   p_[2].segundos=PeriodSeconds(PERIOD_D1);
   p_[3].segundos=PeriodSeconds(PERIOD_H12);
   p_[4].segundos=PeriodSeconds(PERIOD_H8);
   p_[5].segundos=PeriodSeconds(PERIOD_H6);
   p_[6].segundos=PeriodSeconds(PERIOD_H4);
   p_[7].segundos=PeriodSeconds(PERIOD_H3);
   p_[8].segundos=PeriodSeconds(PERIOD_H2);
   p_[9].segundos=PeriodSeconds(PERIOD_H1);
   p_[10].segundos=PeriodSeconds(PERIOD_M30);
   p_[11].segundos=PeriodSeconds(PERIOD_M20);
   p_[12].segundos=PeriodSeconds(PERIOD_M15);
   p_[13].segundos=PeriodSeconds(PERIOD_M12);
   p_[14].segundos=PeriodSeconds(PERIOD_M10);
   p_[15].segundos=PeriodSeconds(PERIOD_M6);
   p_[16].segundos=PeriodSeconds(PERIOD_M5);
   p_[17].segundos=PeriodSeconds(PERIOD_M4);
   p_[18].segundos=PeriodSeconds(PERIOD_M3);
   p_[19].segundos=PeriodSeconds(PERIOD_M2);
   p_[20].segundos=PeriodSeconds(PERIOD_M1);

   p_[0].frecuencia= "MENSUAL";
   p_[1].frecuencia= "SEMANAL";
   p_[2].frecuencia= "DIARIO";
   p_[3].frecuencia= "12 HORAS";
   p_[4].frecuencia= "8 HORAS";
   p_[5].frecuencia= "6 HORAS";
   p_[6].frecuencia= "4 HORAS";
   p_[7].frecuencia= "3 HORAS";
   p_[8].frecuencia= "2 HORAS";
   p_[9].frecuencia= "1 HORA";
   p_[10].frecuencia= "30 MINUTOS";
   p_[11].frecuencia= "20 MINUTOS";
   p_[12].frecuencia= "15 MINUTOS";
   p_[13].frecuencia= "12 MINUTOS";
   p_[14].frecuencia= "10 MINUTOS";
   p_[15].frecuencia= "6 MINUTOS";
   p_[16].frecuencia= "5 MINUTOS";
   p_[17].frecuencia= "4 MINUTOS";
   p_[18].frecuencia= "3 MINUTOS";
   p_[19].frecuencia= "2 MINUTOS";
   p_[20].frecuencia= "1 MINUTO";

   for(int i=0; i<21; i++)
     {
      if(PeriodSeconds(_periodo)!=p_[i].segundos)
         continue;

      return p_[i].frecuencia;
     }

   return "NULL";
  }
  

//+------------------------------------------------------------------+
//| Despues de cierta cantidad de puntos se activa breakEven         |
//+------------------------------------------------------------------+
bool trailingPuntos(
   const string _simboloString,
   const long _magico,
   const bool _activado,
   const int _puntosActivacion,
   const int _puntosDistancia
)
  {

   if(!_activado)
      return true;

//Print("");

   CSymbolInfo _simbolo;

   if(!_simbolo.Name(_simboloString))
      return false;

   bool _salida = true;

   CPositionInfo positionInfo;

   double _sl_propuesto = -1;

   double _sl_actual = -1;

   const double _puntosActivacion2 = _puntosActivacion * _simbolo.Point();

   const double _puntosDistancia2 = _puntosDistancia * _simbolo.Point();

   CTrade _orden;

   _orden.SetExpertMagicNumber(_magico);
   _orden.SetMarginMode();
   _orden.SetTypeFillingBySymbol(_simbolo.Name());
//_orden.SetDeviationInPoints(deslizamiento); // al parecer no es necesario
   _orden.LogLevel(LOG_LEVEL_ALL);

   _simbolo.RefreshRates();

   for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
     {

      if(!positionInfo.SelectByIndex(_cont))
        {

         Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

         if(_LastError == ERR_TRADE_POSITION_NOT_FOUND)
           {
            ResetLastError();
            continue;
           }

         _salida = false;

         continue;

        }

      positionInfo.StoreState();

      if(positionInfo.Symbol() != _simbolo.Name())
         continue;

      if(positionInfo.Magic() != _magico)
         continue;

      _sl_actual = _simbolo.NormalizePrice(positionInfo.StopLoss());

      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
        {

         //if(_sl_actual >= positionInfo.PriceOpen())
         //   continue;

         if(!((_simbolo.Bid() - positionInfo.PriceOpen()) >= _puntosActivacion2))
            continue;

         _sl_propuesto = _simbolo.NormalizePrice(_simbolo.Bid() - _puntosDistancia2);

         if((_simbolo.Bid() - _sl_propuesto) <= (_simbolo.StopsLevel() * _simbolo.Point()))
           {

            Print(
              "\n(Bid - sl) <= StopsLevel, " + __FUNCTION__ +
                  "\nBid: " + DoubleToString(_simbolo.Bid(), _simbolo.Digits()) +
                  "\nsl: " + DoubleToString(_sl_propuesto, _simbolo.Digits()) +
                  "\nstopLevel: " + IntegerToString(_simbolo.StopsLevel())
                 );

            _salida = false;

            continue;

           }

         if(_sl_propuesto <= _sl_actual)
            continue;

        }

      if(positionInfo.PositionType() == POSITION_TYPE_SELL)
        {


         //      if(_sl_actual <= positionInfo.PriceOpen())
         //         continue;


         if(!((positionInfo.PriceOpen() - _simbolo.Ask()) >= _puntosActivacion2))
            continue;

         _sl_propuesto = _simbolo.NormalizePrice(_simbolo.Ask() + _puntosDistancia2);

         if((_sl_propuesto - _simbolo.Ask()) <= (_simbolo.StopsLevel() * _simbolo.Point()))
           {

            Print(
              "\n(sl - Ask) <= StopsLevel, " + __FUNCTION__ +
                  "\nsl: " + DoubleToString(_sl_propuesto, _simbolo.Digits()) +
                  "\nAsk: " + DoubleToString(_simbolo.Ask(), _simbolo.Digits()) +
                  "\nstopLevel: " + IntegerToString(_simbolo.StopsLevel())
                 );

            _salida = false;

            continue;

           }

         if(_sl_propuesto >= _sl_actual)
            continue;

        }

      if(!VerificarPreEstado(_simbolo.Name()))
        {
         _salida = false;

         continue;
        }

      Print("");
      if(!_orden.PositionModify(
            positionInfo.Ticket(),
            _sl_propuesto,
            positionInfo.TakeProfit()
         ))
        {
         Print("!_orden.PositionModify");
         Print("Bid: " + DoubleToString(_simbolo.Bid(), _simbolo.Digits()));
         Print("Ask: " + DoubleToString(_simbolo.Ask(), _simbolo.Digits()));
         Print(EnumToString(positionInfo.PositionType()));
         Print("open: " + DoubleToString(positionInfo.PriceOpen(), _simbolo.Digits()));
         _orden.PrintRequest();
         _orden.PrintResult();

         _salida = false;
        }

      Print("");

     }

//Print("");

   return _salida;
  }

  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EnviarMensajeCelular(const string _mensaje)
  {

   if(MQLInfoInteger(MQL_TESTER))
      return true;

   if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED) == 0)
     {
      Print("notificaciones en el celular no estan activas");
      return false;
     }


   if(TerminalInfoInteger(TERMINAL_MQID) == 0)
     {
      Print("No hay presencia de MetaQuotes ID ");
      return false;
     }

   if(!SendNotification(_mensaje))
     {
      Print("!SendNotification " + IntegerToString(_LastError));
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EnviarMensaje(
   const string _file,
   const string _mensaje,
   const bool _celular
)
  {

   Print(_mensaje);

   if(_celular)
      EnviarMensajeCelular(
         _file + ": " + _mensaje + "\n" + TimeToString(TimeCurrent())
      );

   return true;
  }

//+------------------------------------------------------------------+

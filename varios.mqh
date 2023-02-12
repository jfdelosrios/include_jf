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

   Print("\nVoy a intentar cerrar posiciones.");

   _mensaje = "";

   bool _salida = true;

   CTrade _orden;
//_orden.SetAsyncMode(true);
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.SetMarginMode();
   _orden.LogLevel(LOG_LEVEL_ALL);

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
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitHistorico_(
   const datetime from_date,         // desde el principio
   const datetime to_date, // hasta el momento actual
   const posicionPropia & _posicion[],
   double & _profit
)
  {

   _profit = 0;

   if(!HistorySelect(from_date,to_date))
     {
      Print("!HistorySelect");
      return false;
     }

   bool _salida = true;

   CDealInfo DealInfo;

   const int deals = HistoryDealsTotal();


   for(int _cont = 0; _cont <= (ArraySize(_posicion) - 1); _cont++)
     {

      for(int i = 0; i < deals; i++)
        {

         if(!DealInfo.SelectByIndex(i))
           {
            _salida = false;
            continue;
           }

         if(DealInfo.Entry() != DEAL_ENTRY_OUT)
            continue;

         if(DealInfo.Symbol() != _posicion[_cont].simbolo)
            continue;

         if(DealInfo.Magic() != _posicion[_cont].magico)
            continue;

         _profit += DealInfo.Profit();

        }
     }


   if(TimeCurrent() == D'2022.11.10 13:30:40')
     {
      Print(_profit);
     }

   return _salida;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ProfitHistorico(
   const string _simboloString,
   const long _magico,
   const datetime from_date,         // desde el principio
   const datetime to_date, // hasta el momento actual
   double & _profit
)
  {

   _profit = 0;

   if(!HistorySelect(from_date-1,to_date))
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

      /*
            if(TimeCurrent() >= D'2022.11.10 13:30:40')
              {
              Print(TimeToString(from_date,TIME_DATE|TIME_SECONDS));
               Print(EnumToString(DealInfo.Entry()));
              }
              */
      if(DealInfo.Entry() != DEAL_ENTRY_OUT)
         continue;

      if(DealInfo.Symbol() != _simboloString)
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
   const int _puntos
)
  {

   if(!_activado)
      return true;

//Print("");

   CSymbolInfo m_simboloString;

   if(!m_simboloString.Name(_simboloString))
      return false;

   m_simboloString.RefreshRates();

   bool _salida = true;

   CPositionInfo positionInfo;

   double _sl_propuesto = -1;

   double _sl_actual = -1;

   const double _puntos2 = _puntos * m_simboloString.Point();

   CTrade x_orden;

   x_orden.SetExpertMagicNumber(_magico);
   x_orden.SetMarginMode();
   x_orden.SetTypeFillingBySymbol(m_simboloString.Name());
//x_orden.SetDeviationInPoints(deslizamiento);
   x_orden.LogLevel(LOG_LEVEL_ALL);

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

      if(positionInfo.Symbol() != m_simboloString.Name())
         continue;

      if(positionInfo.Magic() != _magico)
         continue;

      _sl_actual = m_simboloString.NormalizePrice(positionInfo.StopLoss());

      _sl_propuesto = m_simboloString.NormalizePrice(positionInfo.PriceOpen());

      if(positionInfo.PositionType() == POSITION_TYPE_BUY)
        {

         if(_sl_actual >= m_simboloString.NormalizePrice(positionInfo.PriceOpen()))
            continue;

         if(!((m_simboloString.Bid() - positionInfo.PriceOpen()) >= _puntos2))
            continue;

         if(round((m_simboloString.Bid() - _sl_propuesto) / m_simboloString.Point()) <= m_simboloString.StopsLevel())
           {

            Print(
               __FUNCTION__ +
               ", round((simbolo.Bid() - _sl) / simbolo.Point()) <= simbolo.StopsLevel()"
            );

            if(MQLInfoInteger(MQL_TESTER))
               ExpertRemove();

            return true;
           }

        }

      if(positionInfo.PositionType() == POSITION_TYPE_SELL)
        {

         if(_sl_actual <= m_simboloString.NormalizePrice(positionInfo.PriceOpen()))
            continue;

         if(!((positionInfo.PriceOpen() - m_simboloString.Ask()) >= _puntos2))
            continue;

         if(round((_sl_propuesto - m_simboloString.Ask()) / m_simboloString.Point()) <= m_simboloString.StopsLevel())
           {

            Print(
               __FUNCTION__ +
               ", round((_sl - simbolo.Ask()) / simbolo.Point()) <= simbolo.StopsLevel()"
            );

            if(MQLInfoInteger(MQL_TESTER))
               ExpertRemove();

            return true;
           }

        }

      if(!VerificarPreEstado(m_simboloString.Name()))
        {
         _salida = false;

         continue;
        }

      Print("");
      if(!x_orden.PositionModify(positionInfo.Ticket(), _sl_propuesto, positionInfo.TakeProfit()))
        {
         Print("!_orden.PositionModify");
         Print("Bid: " + DoubleToString(m_simboloString.Bid(), m_simboloString.Digits()));
         Print("Ask: " + DoubleToString(m_simboloString.Ask(), m_simboloString.Digits()));
         Print(EnumToString(positionInfo.PositionType()));
         Print("open: " + DoubleToString(positionInfo.PriceOpen(), m_simboloString.Digits()));
         x_orden.PrintRequest();
         x_orden.PrintResult();

         _salida = false;
        }

      Print("");

     }

//Print("");

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarTodasLasPosiciones_1(
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

            Print("*/");
            Print("!PositionClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();
            Print("Error: " + IntegerToString(_LastError));
            Print("*/");

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

      Print("\nVoy a intentar contar posiciones.");

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
         Print(IntegerToString(_contPosiciones) + " posiciones abiertas.");
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
         Print(IntegerToString(_contOrdenes) + " ordenes pendientes.");
         return _contOrdenes;
        }

      Print("Error, voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BorrarPendientes_old(
   const string _simboloString,
   const ulong _magico,
   const ulong Slippage
)
  {

   Print("\nVoy a intentar cerrar pendientes.");

   COrderInfo _orderInfo;

   CTrade _orden;

   _orden.SetExpertMagicNumber(_magico);
   _orden.SetMarginMode();
   _orden.SetTypeFillingBySymbol(_simboloString);
   _orden.SetDeviationInPoints(Slippage);
   _orden.SetAsyncMode(true);

   for(int cnt = (OrdersTotal() - 1); cnt >= 0; cnt--)
     {

      if(!_orderInfo.SelectByIndex(cnt))
        {
         continue;
        }

      _orderInfo.StoreState();

      if(_orderInfo.Magic() != _magico)
         continue;

      if(_orderInfo.Symbol() != _simboloString)
         continue;

      if(!(
            (_orderInfo.OrderType() == ORDER_TYPE_SELL_STOP)
            ||
            (_orderInfo.OrderType() == ORDER_TYPE_BUY_STOP)
         ))
         continue;

      if(!_orden.OrderDelete(_orderInfo.Ticket()))
        {
         Print("Ocurrió un error al intentar borrar la operación");
        }

     }

   return true;

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
   /*
      if(trans.price_sl == 0)
         return false;
   */
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
//|                                                                  |
//+------------------------------------------------------------------+
bool BorrarTodasLasPendientes(const ulong _deslizamiento, string &_mensaje)
  {

   _mensaje = "";

   bool _salida = true;

   CTrade _orden;

   _orden.SetDeviationInPoints(_deslizamiento);

   COrderInfo _orderInfo;

   for(int _cont = (OrdersTotal() - 1); _cont >= 0; _cont--)
     {

      if(!_orderInfo.SelectByIndex(_cont))
        {

         if(_LastError == ERR_TRADE_ORDER_NOT_FOUND)
           {
            ResetLastError();
            continue;
           }

         Print(__FUNCTION__ + ", error " + IntegerToString(_LastError));

         _salida = false;

         continue;
        }

      _orderInfo.StoreState();

      if(!_orden.OrderDelete(_orderInfo.Ticket()))
        {

         _salida = false;

         Print("----");
         Print("!_ordenClose " + IntegerToString(_LastError));
         _orden.PrintResult();
         _orden.PrintRequest();
         Print("----");

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
bool BorrarTodasLasPendientesCondicionada(
   posicionPropia &_posicion[],
   string &_mensaje,
   const ulong _deslizamiento
)
  {

   if(ArraySize(_posicion) == 0)
     {
      return BorrarTodasLasPendientes(_deslizamiento, _mensaje);
     }

   Print("\nVoy a intentar borrar ordenes pendientes.");

   _mensaje = "";

   bool _salida = true;

   CTrade _orden;
//_orden.SetAsyncMode(true);
   _orden.SetMarginMode();
   _orden.SetDeviationInPoints(_deslizamiento);
   _orden.LogLevel(LOG_LEVEL_ALL);

   COrderInfo _orderInfo;

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

         _mensaje += "No puedo Borrar Pendientes en " +
                     _posicion[i].simbolo +
                     ". Mercado cerrado."
                     ;

         _salida = false;
         continue;

        }

      _orden.SetTypeFillingBySymbol(_posicion[i].simbolo);
      _orden.SetExpertMagicNumber(_posicion[i].magico);

      for(int _cont = (OrdersTotal() - 1); _cont >= 0; _cont--)
        {

         if(!_orderInfo.SelectByIndex(_cont))
           {

            if(_LastError == ERR_TRADE_ORDER_NOT_FOUND)
              {
               ResetLastError();
               continue;
              }

            Print(__FUNCTION__ + ", error "+IntegerToString(_LastError));

            _salida = false;

            continue;
           }

         _orderInfo.StoreState();

         if(_orderInfo.Symbol() != _posicion[i].simbolo)
            continue;

         if(_orderInfo.Magic() != _posicion[i].magico)
            continue;

         if(!_orden.OrderDelete(_orderInfo.Ticket()))
           {

            _salida = false;

            Print("*/");
            Print("!_ordenClose " + IntegerToString(_LastError));
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
bool BorrarTodasLasPendientes_1(
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

            Print("*/");
            Print("!_ordenClose " + IntegerToString(_LastError));
            _orden.PrintResult();
            _orden.PrintRequest();
            Print("Error: " + IntegerToString(_LastError));
            Print("*/");

            if(MQLInfoInteger(MQL_TESTER))
               return false;

            ResetLastError();

            break;

           }

        }

      if(_salida)
        {
         Print("Pude cancelar todas las ordenes.");
         return true;
        }

      Print("Voy a volver a intentar.");

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool profitFlotante(const string _simboloString, const long _magico, double & _profit)
  {

   _profit = 0;

   bool _salida = true;

   CPositionInfo positionInfo;

   const int _total = PositionsTotal();

//for(int _cont = (PositionsTotal() - 1); _cont >= 0; _cont--)
   for(int _cont = 0; _cont < _total; _cont++)
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

      if(positionInfo.Symbol() != _simboloString)
         continue;

      if(positionInfo.Magic() != _magico)
         continue;

      positionInfo.StoreState();

      _profit += positionInfo.Profit();

     }

   return _salida;

  }
//+------------------------------------------------------------------+

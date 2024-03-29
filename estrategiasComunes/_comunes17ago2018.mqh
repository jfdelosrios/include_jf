//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#include "gestion17ago2018.mqh"
#ifdef __MQL4__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_POSITION_TYPE
  {
   POSITION_TYPE_BUY,
   POSITION_TYPE_SELL
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRADE_REQUEST_ACTIONS
  {
   TRADE_ACTION_DEAL,
   TRADE_ACTION_PENDING,
   TRADE_ACTION_SLTP,
   TRADE_ACTION_MODIFY,
   TRADE_ACTION_REMOVE,
   TRADE_ACTION_CLOSE_BY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ORDER_TYPE_FILLING
  {
   ORDER_FILLING_FOK,
   ORDER_FILLING_IOC,
   ORDER_FILLING_RETURN
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ORDER_TYPE_TIME
  {
   ORDER_TIME_GTC,
   ORDER_TIME_DAY,
   ORDER_TIME_SPECIFIED,
   ORDER_TIME_SPECIFIED_DAY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MqlTradeRequest
  {
   ENUM_TRADE_REQUEST_ACTIONS action;           // Tipo de acción que se ejecuta
   int               magic;            // ID del Asesor Experto (identificador magic number)
   ulong             order;            // Ticket de la orden
   string            symbol;           // Nombre del instrumento comercial
   double            volume;           // Volumen solicitado de la transacción en lotes
   double            price;            // Precio 
   double            stoplimit;        // Nivel StopLimit de la orden
   double            sl;               // Nivel Stop Loss de la orden
   double            tp;               // Nivel Take Profit de la orden
   int               deviation;        // Desviación máxima aceptable del precio solicitado
   ENUM_ORDER_TYPE   type;             // Tipo de orden
   ENUM_ORDER_TYPE_FILLING type_filling;     // Tipo de ejecución de la orden
   ENUM_ORDER_TYPE_TIME type_time;        // Tipo de orden por su plazo de ejecución 
   datetime          expiration;       // Plazo de expiración de la orden (para las órdenes del tipo ORDER_TIME_SPECIFIED)
   string            comment;          // Comentarios sobre la orden
   ulong             position;         // Position ticket
   ulong             position_by;      // Comentarios sobre la orden
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MqlPosicionHistory
  {
   double            OrderClosePrice1; //
   datetime          OrderCloseTime1; //
   string            OrderComment1; //
   double            OrderCommission1; //
   datetime          OrderExpiration1; //
   double            OrderLots1; //
   int               OrderMagicNumber1; //
   double            OrderOpenPrice1; //
   datetime          OrderOpenTime1; //
   double            OrderProfit1; //
   double            OrderStopLoss1; //
   double            OrderSwap1; //
   string            OrderSymbol1; //
   double            OrderTakeProfit1; //
   int               OrderTicket1; //
   int               OrderType1; //
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool seleccionarPosicionHistorico(const int i,const char tipoBusqueda,MqlPosicionHistory &posicion1)
  {
ZeroMemory(posicion1);

   if(!OrderSelect(i,SELECT_BY_POS))
      return false;

   posicion1.OrderClosePrice1=OrderClosePrice(); //
   posicion1.OrderCloseTime1=OrderCloseTime(); //
   posicion1.OrderComment1=OrderComment(); //
   posicion1.OrderCommission1=OrderCommission(); //
   posicion1.OrderExpiration1=OrderExpiration(); //
   posicion1.OrderLots1=OrderLots(); //
   posicion1.OrderMagicNumber1=OrderMagicNumber(); //
   posicion1.OrderOpenPrice1=OrderOpenPrice(); //
   posicion1.OrderOpenTime1=OrderOpenTime(); //
   posicion1.OrderProfit1=OrderProfit(); //
   posicion1.OrderStopLoss1=OrderStopLoss(); //
   posicion1.OrderSwap1=OrderSwap(); //
   posicion1.OrderSymbol1=OrderSymbol(); //
   posicion1.OrderTakeProfit1=OrderTakeProfit(); //
   posicion1.OrderTicket1=OrderTicket(); //
   posicion1.OrderType1=OrderType(); //

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MqlTradeResult
  {
   uint              retcode;          // Código del resultado de operación
   ulong             deal;             // Ticket de transacción, si está concluida
   ulong             order;            // Ticket de la orden, si está colocada
   double            volume;           // Volumen de la transacción confirmado por el corredor
   double            price;            // Precio en la transacción confirmada por el corredor
   double            bid;              // Precio actual de la oferta en el mercado (precios recuota)
   double            ask;              // Precio actual de la demanda en el mercado (precios recuota)
   string            comment;          // 
   uint              request_id;       // El terminal pone el identificador de la solicitud a la hora de enviarla 
   uint              retcode_external; // Código de respuesta del sistema de comercio exterior
  };
#endif
//+------------------------------------------------------------------+

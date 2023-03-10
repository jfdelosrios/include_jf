//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property library
#property strict
#include <comunes17ago2018.mqh>
#include <gestion17ago2018.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool obsoleto() export
  {
   if(TimeCurrent()>D'2019.02.01 00:00')
     {
      Print("Error 20389");
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CerrarOperacionesOriginal(const int magico50,const EnumTipoOperacion tipoOperacion54) export
  {
   if(obsoleto())
     {
      return false;
     }
//long digitos;
//double puntos;
   double bid;
   double ask;
//long stopLevel;
//double stopLossActual;
   MqlTradeResult result={0};
   MqlTradeRequest request={0};

#ifdef __MQL5__
   const int totalito=PositionsTotal();
#endif

   ENUM_POSITION_TYPE tipoPosicion;

#ifdef __MQL4__
   const int totalito=OrdersTotal();
#endif

   for(int cont50=(totalito-1);cont50>=0;cont50--)
     {
      ZeroMemory(request);
      ZeroMemory(result);

#ifdef __MQL5__


      if(PositionGetTicket(cont50)==0)
         return(false);


      tipoPosicion=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(tipoPosicion==POSITION_TYPE_BUY)
        {
         request.type=(ENUM_ORDER_TYPE)CORTO;
        }
      else //if(tipoPosicion==POSITION_TYPE_SELL)
        {
         request.type=(ENUM_ORDER_TYPE)LARGO;
        }

      if(!PositionGetInteger(POSITION_TICKET,request.position))
         return(false);
      if(!PositionGetDouble(POSITION_VOLUME,request.volume))
         return(false);
      if(!PositionGetInteger(POSITION_MAGIC,request.magic))
         return(false);
      if(!PositionGetString(POSITION_SYMBOL,request.symbol))
         return(false);




#endif

#ifdef __MQL4__
      if(!OrderSelect(cont50,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error OrderSelect, breakEven "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      tipoPosicion=(ENUM_POSITION_TYPE)OrderType();

      request.position=OrderTicket();
      request.volume=OrderLots();
      request.magic=OrderMagicNumber();
      request.symbol=OrderSymbol();

      if(OrderType()==CORTO)
        {
         request.type=(ENUM_ORDER_TYPE)LARGO;
        }
      else
        {
         request.type=(ENUM_ORDER_TYPE)CORTO;
        }
#endif

      if(request.magic!=magico50)
         continue;

      if((tipoPosicion==POSITION_TYPE_BUY) && (tipoOperacion54==CORTO))
         continue;

      if((tipoPosicion==POSITION_TYPE_SELL) && (tipoOperacion54==LARGO))
         continue;

      if(!SymbolInfoDouble(request.symbol,SYMBOL_BID,bid))
        {
         Print("Error: AplicarBreakEven bid "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_ASK,ask))
        {
         Print("Error: AplicarBreakEven ask "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(tipoOperacion54==LARGO)
        {
         request.price=bid;
        }
      else // if(tipoOperacion54==CORTO)
        {
         request.price=ask;
        }

      request.deviation=2;
      request.type_filling=ORDER_FILLING_IOC;
      request.action=TRADE_ACTION_DEAL;

      if(!EnviarOrden(request,result,"cerrar"))
         return(false);
     }
   return(true);
  }

bool CerrarOperaciones(const EnumTipoOperacion tipoOperacion54,CTrade &ExtTrade1) export
  {
   if(obsoleto())
     {
      return false;
     }
     
   MqlTradeRequest request={0};

#ifdef __MQL5__
   const int totalito=PositionsTotal();
#endif

   ENUM_POSITION_TYPE tipoPosicion;

#ifdef __MQL4__
   const int totalito=OrdersTotal();
#endif

   for(int cont50=(totalito-1);cont50>=0;cont50--)
     {
      ZeroMemory(request);

#ifdef __MQL5__


      if(PositionGetTicket(cont50)==0)
         return(false);


      tipoPosicion=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(tipoPosicion==POSITION_TYPE_BUY)
        {
         request.type=(ENUM_ORDER_TYPE)CORTO;
        }
      else //if(tipoPosicion==POSITION_TYPE_SELL)
        {
         request.type=(ENUM_ORDER_TYPE)LARGO;
        }

      if(!PositionGetInteger(POSITION_TICKET,request.position))
         return(false);
      if(!PositionGetDouble(POSITION_VOLUME,request.volume))
         return(false);
      if(!PositionGetInteger(POSITION_MAGIC,request.magic))
         return(false);
      if(!PositionGetString(POSITION_SYMBOL,request.symbol))
         return(false);

#endif

#ifdef __MQL4__
      if(!OrderSelect(cont50,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error OrderSelect, breakEven "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      tipoPosicion=(ENUM_POSITION_TYPE)OrderType();

      request.position=OrderTicket();
      request.volume=OrderLots();
      request.magic=OrderMagicNumber();
      request.symbol=OrderSymbol();

      if(OrderType()==CORTO)
        {
         request.type=(ENUM_ORDER_TYPE)LARGO;
        }
      else
        {
         request.type=(ENUM_ORDER_TYPE)CORTO;
        }
#endif

      if(request.magic!=ExtTrade1.RequestMagic())
         continue;

      if((tipoPosicion==POSITION_TYPE_BUY) && (tipoOperacion54==CORTO))
         continue;

      if((tipoPosicion==POSITION_TYPE_SELL) && (tipoOperacion54==LARGO))
         continue;
 
      if(!ExtTrade1.PositionClose(request.position))
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MagicoSeEstaUsando(int magico5050) export
  {
   for(int cont5050=(OrdersTotal()-1);cont5050>=0;cont5050--)
     {
#ifdef __MQL5__
      if(OrderGetTicket(cont5050)==0)
         continue;

      if(OrderGetInteger(ORDER_MAGIC)==magico5050)
         return(true);
#endif

#ifdef __MQL4__
      if(!OrderSelect(cont5050,SELECT_BY_POS))
         continue;

      if(OrderMagicNumber()==magico5050)
        {
         Print("pasa1");

         return(true);
        }
#endif
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AplicarTrailingStop(const int trailing50,const int magico50) export
  {
   if(trailing50<1)
      return(false);

   long digitos;
   double puntos;
   double bid;
   double ask;
   long stopLevel;
   double stopLossActual;
   MqlTradeResult result={0};
   MqlTradeRequest request={0};
#ifdef __MQL5__
   ENUM_POSITION_TYPE tipoPosicion;
   const int totalito=PositionsTotal();
#endif

#ifdef __MQL4__
   const int totalito=OrdersTotal();
#endif

   for(int cont50=(totalito-1);cont50>=0;cont50--)
     {
      ZeroMemory(request);
      ZeroMemory(result);

#ifdef __MQL5__
      if(PositionGetTicket(cont50)==0)
         return(false);
      request.action=TRADE_ACTION_SLTP;

      if(!PositionGetInteger(POSITION_TICKET,request.position))
         return(false);
      if(!PositionGetString(POSITION_SYMBOL,request.symbol))
         return(false);
      if(!PositionGetDouble(POSITION_SL,stopLossActual))
         return(false);
      if(!PositionGetDouble(POSITION_TP,request.tp))
         return(false);
      if(!PositionGetInteger(POSITION_MAGIC,request.magic))
         return(false);
      if(!PositionGetDouble(POSITION_PRICE_OPEN,request.price))
         return(false);


      tipoPosicion=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(tipoPosicion==POSITION_TYPE_BUY)
        {
         request.type=ORDER_TYPE_BUY;
        }
      else// if(tipoPosicion==POSITION_TYPE_SELL)
        {
         request.type=ORDER_TYPE_SELL;
        }
#endif

#ifdef __MQL4__
      if(!OrderSelect(cont50,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error OrderSelect, breakEven "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      request.action=TRADE_ACTION_SLTP;
      request.position=OrderTicket();
      request.symbol=OrderSymbol();
      request.tp=OrderTakeProfit();
      request.magic=OrderMagicNumber();
      request.type=(ENUM_ORDER_TYPE)OrderType();
      request.price=OrderOpenPrice();
      request.expiration=OrderExpiration();
      stopLossActual=OrderStopLoss();
#endif

      if(request.magic!=magico50)
         continue;

      if(!SymbolInfoInteger(request.symbol,SYMBOL_DIGITS,digitos))
        {
         Print("Error: AplicarBreakEven digitos "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoInteger(request.symbol,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
        {
         Print("Error: AplicarBreakEven stopLevel2 "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_POINT,puntos))
        {
         Print("Error: AplicarBreakEven puntos "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_BID,bid))
        {
         Print("Error: AplicarBreakEven bid "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_ASK,ask))
        {
         Print("Error: AplicarBreakEven ask "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(trailing50<stopLevel)
        {
         Print("Error: Trailing es menor a stopLevel2 ("+
               IntegerToString(trailing50)+" < "+IntegerToString(stopLevel)+").");
         ExpertRemove();
         return(false);
        }

      if(request.type==(ENUM_ORDER_TYPE)LARGO)
        {
         if(request.price>stopLossActual)
            continue;

         request.sl=NormalizeDouble((bid-(trailing50*puntos)),(int)digitos);

         if(request.sl<=stopLossActual)
            continue;

         if(request.sl<=0)
           {
            Print("Error slNegativo Sell, breakEven");
            ExpertRemove();
            return(false);
           }

         if(!EnviarOrden(request,result))
           {
            Print("Error OrderModify Buy, breakEven "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }
         continue;
        }

      if(request.type==(ENUM_ORDER_TYPE)CORTO)
        {
         if(request.price<stopLossActual)
            continue;

         request.sl=NormalizeDouble((ask+(trailing50*puntos)),(int)digitos);

         if(request.sl>=stopLossActual)
            continue;

         if(request.sl<=0)
           {
            Print("Error slNegativo Sell, breakEven");
            ExpertRemove();
            return(false);
           }

         if(!EnviarOrden(request,result))
           {
            Print("Error OrderModify Buy, breakEven "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }

         continue;
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  AplicarBreakEven(const int breakEven50,const int adicionBreak50,const int magico50) export
  {
   if(breakEven50<1)
      return(false);

   long digitos;
   double puntos;
   double bid;
   double ask;
   long stopLevel;
   double stopLossActual;
   MqlTradeResult result={0};
   MqlTradeRequest request={0};

#ifdef __MQL5__
   ENUM_POSITION_TYPE tipoPosicion;
   const int totalito=PositionsTotal();
#endif

#ifdef __MQL4__
   const int totalito=OrdersTotal();
#endif

   for(int cont50=(totalito-1);cont50>=0;cont50--)
     {
      ZeroMemory(request);
      ZeroMemory(result);

#ifdef __MQL5__
      if(PositionGetTicket(cont50)==0)
         return(false);
      request.action=TRADE_ACTION_SLTP;

      if(!PositionGetInteger(POSITION_TICKET,request.position))
         return(false);
      if(!PositionGetString(POSITION_SYMBOL,request.symbol))
         return(false);
      if(!PositionGetDouble(POSITION_SL,stopLossActual))
         return(false);
      if(!PositionGetDouble(POSITION_TP,request.tp))
         return(false);
      if(!PositionGetInteger(POSITION_MAGIC,request.magic))
         return(false);
      if(!PositionGetDouble(POSITION_PRICE_OPEN,request.price))
         return(false);
      if(!PositionGetDouble(POSITION_VOLUME,request.volume))
         return(false);


      tipoPosicion=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(tipoPosicion==POSITION_TYPE_BUY)
        {
         request.type=ORDER_TYPE_BUY;
        }
      else// if(tipoPosicion==POSITION_TYPE_SELL)
        {
         request.type=ORDER_TYPE_SELL;
        }
#endif

#ifdef __MQL4__

      if(!OrderSelect(cont50,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error OrderSelect, breakEven "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      request.action=TRADE_ACTION_SLTP;
      request.position=OrderTicket();
      request.symbol=OrderSymbol();
      request.tp=OrderTakeProfit();
      request.magic=OrderMagicNumber();
      request.type=(ENUM_ORDER_TYPE)OrderType();
      request.price=OrderOpenPrice();
      request.expiration=OrderExpiration();
      stopLossActual=OrderStopLoss();
#endif

      if(request.magic!=magico50)
         continue;

      if(!SymbolInfoInteger(request.symbol,SYMBOL_DIGITS,digitos))
        {
         Print("Error: AplicarBreakEven digitos "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoInteger(request.symbol,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
        {
         Print("Error: AplicarBreakEven stopLevel2 "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_POINT,puntos))
        {
         Print("Error: AplicarBreakEven puntos "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_BID,bid))
        {
         Print("Error: AplicarBreakEven bid "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!SymbolInfoDouble(request.symbol,SYMBOL_ASK,ask))
        {
         Print("Error: AplicarBreakEven ask "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if((breakEven50+adicionBreak50)<stopLevel)
        {
         Print("Error: BreakEven mas adicionBreak es menor a stopLevel2 (("+IntegerToString(breakEven50)+" + "+
               IntegerToString(adicionBreak50)+") < "+IntegerToString(stopLevel)+").");
         ExpertRemove();
         return(false);
        }

      if((bid-(breakEven50*puntos))<=0)
        {
         Print("Error: (bid-(breakEven50*puntos)) negativo");
         ExpertRemove();
         return(false);
        }

      if((ask+(breakEven50*puntos))<=0)
        {
         Print("Error: (ask+(breakEven50*puntos)) negativo");
         ExpertRemove();
         return(false);
        }

      if((request.type==(ENUM_ORDER_TYPE)LARGO))
        {
         if(stopLossActual>=request.price)
            continue;

         request.sl=NormalizeDouble((request.price+(adicionBreak50*puntos)),(int)digitos);
         if(request.sl<=0)
           {
            Print("Error slNegativo Sell, breakEven");
            ExpertRemove();
            return(false);
           }

         if(request.sl<=stopLossActual)
            continue;

         if(((bid-(breakEven50*puntos)))<(request.sl))
            continue;

         if(!EnviarOrden(request,result))
           {
            Print("Error OrderModify Buy, breakEven "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }
         continue;
        }

      if(request.type==(ENUM_ORDER_TYPE)CORTO)
        {
         if(stopLossActual<=request.price)
            continue;

         request.sl=(request.price-(adicionBreak50*puntos));
         if(request.sl<=0)
           {
            Print("Error slNegativo Sell, breakEven");
            ExpertRemove();
            return(false);
           }

         if(request.sl>=stopLossActual)
            continue;

         if(((ask+(breakEven50*puntos))>request.sl))
            continue;

         if(!EnviarOrden(request,result))
           {
            Print("Error OrderModify Buy, breakEven "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }
         continue;
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Hammer(
            const int barra50,
            const string simbolo50,
            const ENUM_TIMEFRAMES periodo50
            ) export
  {

   if(barra50<0)
     {
      Print("No hammer. Indice negativo.");
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);
#endif

   const uchar cantVelas=1; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      Print("No hammer. No hay suficiente cantidad de velas.");
      return(false);
     }

   const double tamanoTotal=High[barra50]-Low[barra50];

   if(tamanoTotal==0)
     {
      Print("No hammer. maximo es igual a minimo.");
      return(false);
     }

   const double porcentajeMechaSuperior=((High[barra50]-MathMax(Close[barra50],Open[barra50]))/tamanoTotal);

   if(porcentajeMechaSuperior>0.1)
     {
      Print("No hammer. Mecha superior es mayor a 10% ("+DoubleToString(porcentajeMechaSuperior*100,2)+"%).");
      return(false);
     }

   const double tamanoMecha=(MathMin(Close[barra50],Open[barra50])-Low[barra50]);
   const double tamanoCuerpo=MathAbs(Close[barra50]-Open[barra50]);

   if(tamanoMecha<(tamanoCuerpo*3))
     {
      Print("No hammer. Tamano de la mecha inferior es menor a tres veces el cuerpo ("
            +DoubleToString(tamanoMecha,_Digits)+" < "+DoubleToString(tamanoCuerpo*3,_Digits)+").");
      return(false);
     }

   Print("Es hammer");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShootingStar(
                  const int barra50,
                  const string simbolo50,
                  const ENUM_TIMEFRAMES periodo50,
                  ) export
  {
   if(barra50<0)
     {
      Print("No shooting Star. Indice negativo");
      ExpertRemove();
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);
#endif

   const uchar cantVelas=1; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      Print("No shooting Star. No hay suficiente cantidad de velas.");
      return(false);
     }

   const double tamanoTotal=High[barra50]-Low[barra50];

   if(tamanoTotal==0)
     {
      Print("No shooting Star. maximo es igual a minimo.");
      return(false);
     }
   const double mechaPequenaPorcentual=(MathMin(Close[barra50],Open[barra50])-Low[barra50])/tamanoTotal;

   if(mechaPequenaPorcentual>0.1)
     {
      Print("No shooting Star. Mecha inferior es mayor a 10% ("+DoubleToString(mechaPequenaPorcentual*100,2)+"%).");
      return(false);
     }

   const double tamanoMecha=(High[barra50]-MathMax(Close[barra50],Open[barra50]));
   const double tamanoCuerpo=MathAbs(Close[barra50]-Open[barra50]);

   if(tamanoMecha<(tamanoCuerpo*3))
     {
      Print("No shooting Star. Tamano de la mecha superior es menor a tres veces el cuerpo ("
            +DoubleToString(tamanoMecha,_Digits)+" < "+DoubleToString(tamanoCuerpo*3,_Digits)+").");
      return(false);
     }

   Print("Es shooting star.");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PseudoEngulfing(
                     const int barra50,
                     const double cuerpoRequerido50,
                     const EnumTipoOperacion tipoOperacion50,
                     const string simbolo50,
                     const ENUM_TIMEFRAMES periodo50) export
  {
   if(barra50<0)
     {
      return(false);
     }

   if((cuerpoRequerido50>1) || (cuerpoRequerido50<0))
     {
      Print("Cuerpo mal parametrizado para pseudoengulfing");
      return(false);
     }

   const uchar cantVelas=2; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      Print("No hay suficientes velas para pseudoengulfing");
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);
#endif

   double tamano=High[barra50]-Low[barra50];

   if(tamano<=0)
     {
      return(false);
     }

   tamano=MathAbs(Close[barra50]-Open[barra50])/tamano;

   if(tamano<cuerpoRequerido50)
     {
      Print("Cuerpo muy pequeño para pseudoengulfing ("+DoubleToString(tamano*100,2)+"% < "+
            DoubleToString(cuerpoRequerido50*100,2)+"%)");
      return(false);
     }

   if(tipoOperacion50==LARGO)
     {
      if(!(((Close[barra50]>High[barra50+1])) && (Close[barra50]>Open[barra50])))
        {
         Print("No hay engulfing alcista.");
         return(false);
        }
      else
        {
         Print("Hay engulfing alcista.");
        }
     }

   if(tipoOperacion50==CORTO)
     {
      if(!(((Close[barra50]<Low[barra50+1])) && (Close[barra50]<Open[barra50])))
        {
         Print("No hay engulfing bajista.");
         return(false);
        }
      else
        {
         Print("Hay engulfing bajista.");
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AnalizaATR_1(const int ATR_1periodo3,const double ATR_1relacionMin3,const double ATR_1relacionMax3) export
  {
   double ATR_1[];

   if(!ArraySetAsSeries(ATR_1,true))
      return(false);

#ifdef __MQL5__
   double Low[];
   if(!ArraySetAsSeries(Low,true))
     {
      Print("Error ArraySerAsSerie Low AbrirLargo "+IntegerToString(_LastError));
      ExpertRemove();
      return(false);
     }

   if(CopyLow(_Symbol,PERIOD_CURRENT,0,2,Low)==-1)
     {
      Print("Error CopyHigh AbrirLargo "+IntegerToString(_LastError));
      ExpertRemove();
      return(false);
     }

   double High[];
   if(!ArraySetAsSeries(High,true))
     {
      Print("Error ArraySerAsSerie High AbrirCorto "+IntegerToString(_LastError));
      ExpertRemove();
      return(false);
     }

   if(CopyHigh(_Symbol,PERIOD_CURRENT,0,2,High)==-1)
     {
      Print("Error CopyHigh AbrirCorto "+IntegerToString(_LastError));
      ExpertRemove();
      return(false);
     }
   const int ATR_1Handle=iATR(_Symbol,_Period,ATR_1periodo3);

   if(CopyBuffer(ATR_1Handle,0,0,2,ATR_1)==-1)
      return(false);

#endif


#ifdef __MQL4__
   if(ArrayResize(ATR_1,2)==-1)
      return(false);

   ATR_1[1]=iATR_1(_Symbol,_Period,ATR_1periodo3,1);
#endif

   const double relacionVelaATR_1=((High[1]-Low[1]))/ATR_1[1];

   if(relacionVelaATR_1<=ATR_1relacionMin3)
     {
      Print("relacion ATR_1 y vela "+DoubleToString(relacionVelaATR_1*100,2)+"% es menor a "+DoubleToString(ATR_1relacionMin3*100,2)+"%.");
      return(false);
     }

   if(relacionVelaATR_1>=ATR_1relacionMax3)
     {
      Print("relacion ATR_1 y vela "+DoubleToString(relacionVelaATR_1*100,2)+"% es mayor a "+DoubleToString(ATR_1relacionMax3*100,2)+"%.");
      return(false);
     }

   Print("relacion ATR_1 y tamaño de vela "+DoubleToString(relacionVelaATR_1*100,2)+"% es aceptable. ");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Doji(const int barra50,const double cuerpoRequerido50,const string simbolo50,const ENUM_TIMEFRAMES periodo50) export
  {
   if(barra50<0)
     {
      return(false);
     }

   if((cuerpoRequerido50>1) || (cuerpoRequerido50<0))
     {
      return(false);
     }

   const uchar cantVelas=1; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);

   datetime Time[];
   ArraySetAsSeries(Time,true);
   CopyTime(simbolo50,periodo50,0,barra50,Time);
#endif
   const double tamano=High[barra50]-Low[barra50];

   if(tamano<=0)
     {
      return(false);
     }

   Print(DoubleToString(MathAbs(Close[barra50]-Open[barra50])/tamano)+"  "+TimeToString(Time[barra50]));

   if((MathAbs(Close[barra50]-Open[barra50])/tamano)>=cuerpoRequerido50)
     {
      //Print("cuerpo muy grande con respecto a mechas");
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PocasOrdenesAbiertas(const int magico54,const int maximoOrdenes,const EnumTipoOperacion tipoOrden=CUALQUIERA,const bool comentario=false) export
  {
   int cantidadOrdenes3;

   if(!CantidadOrdenesAbiertasMagico(magico54,cantidadOrdenes3,tipoOrden))
     {
      return(false);
     }

   if(cantidadOrdenes3>=maximoOrdenes)
     {
      if(comentario)
         Print("No se pueden abrir mas de "+IntegerToString(maximoOrdenes)+" ordenes.");
      return(false);
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CantidadOrdenesAbiertasMagico(const int magicoBuscado,int &cantidadOrdenesMagico,const EnumTipoOperacion tipoOrden=CUALQUIERA) export
  {
   cantidadOrdenesMagico=0;

#ifdef __MQL5__
   const int totalito=PositionsTotal();
#endif

#ifdef __MQL4__
   const int totalito=OrdersTotal();
#endif

   long magicoPosicion;
   ENUM_POSITION_TYPE tipoPosicion;
   ENUM_POSITION_TYPE tipoPosicionBuscada;

   if(tipoOrden==LARGO)
     {
      tipoPosicionBuscada=POSITION_TYPE_BUY;
     }
   else//if(tipoOrden==CORTO)
     {
      tipoPosicionBuscada=POSITION_TYPE_SELL;
     }

   for(int cont=(totalito-1);cont>=0;cont--)
     {

#ifdef __MQL5__
      if(PositionGetTicket(cont)==0)
        {
         Print("Error: DemaciadasAbiertas. PositionGetTicket Error: "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      if(!PositionGetInteger(POSITION_MAGIC,magicoPosicion))
        {
         Print("Error: DemaciadasAbiertas PositionGetInteger ORDER_MAGIC. Error: "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      tipoPosicion=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

#endif

#ifdef __MQL4__
      if(!OrderSelect(cont,SELECT_BY_POS,MODE_TRADES))
        {
         Print("Error: DemaciadasAbiertas. OrderSelect. Error: "+IntegerToString(_LastError));
         ExpertRemove();
         return(false);
        }

      magicoPosicion=OrderMagicNumber();

      if(OrderType()==LARGO)
        {
         tipoPosicion=POSITION_TYPE_BUY;
        }
      else//if(tipoOrden==CORTO)
        {
         tipoPosicion=POSITION_TYPE_SELL;
        }

#endif

      if(magicoPosicion!=magicoBuscado)
        {
         continue;
        }

      if((tipoPosicion==tipoPosicionBuscada) || (tipoOrden==CUALQUIERA))
        {
         cantidadOrdenesMagico++;
        }
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Hammer2(
             const int barra50,
             const string simbolo50,
             const ENUM_TIMEFRAMES periodo50,
             const double mechaGrandotai,
             const double mechaPequenai
             ) export
  {
   if(barra50<0)
     {
      Print("No hammer. Indice negativo.");
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);
#endif

   const uchar cantVelas=1; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      Print("No hammer. No hay suficiente cantidad de velas.");
      return(false);
     }

   const double tamanoTotal=High[barra50]-Low[barra50];

   if(tamanoTotal==0)
     {
      Print("No hammer. maximo es igual a minimo.");
      return(false);
     }

   const double mechaSuperior=((High[barra50]-MathMax(Close[barra50],Open[barra50]))/tamanoTotal);

   if(mechaSuperior>mechaPequenai)
     {
      Print("No hammer.  Mecha superior es mayor a tamano requerido ("+DoubleToString(mechaSuperior*100,2)+"% > "+DoubleToString(mechaPequenai*100,2)
            +"%).");
      return(false);
     }

   const double mechaInferior=(MathMin(Close[barra50],Open[barra50])-Low[barra50])/tamanoTotal;

   if(mechaInferior<mechaGrandotai)
     {
      Print("No hammer. Mecha inferior es menor a tamano requerido ("+DoubleToString(mechaInferior*100,2)+"% < "+DoubleToString(mechaGrandotai*100,2)
            +"%).");
      return(false);
     }

   Print("Es hammer");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShootingStar2(
                   const int barra50,
                   const string simbolo50,
                   const ENUM_TIMEFRAMES periodo50,
                   const double mechaGrandotai,
                   const double mechaPequenai
                   ) export
  {
   if(barra50<0)
     {
      Print("No shooting Star. Indice negativo");
      ExpertRemove();
      return(false);
     }

#ifdef __MQL5__
   double High[];
   ArraySetAsSeries(High,true);
   CopyHigh(simbolo50,periodo50,0,barra50,High);

   double Low[];
   ArraySetAsSeries(Low,true);
   CopyLow(simbolo50,periodo50,0,barra50,Low);

   double Close[];
   ArraySetAsSeries(Close,true);
   CopyClose(simbolo50,periodo50,0,barra50,Close);

   double Open[];
   ArraySetAsSeries(Open,true);
   CopyOpen(simbolo50,periodo50,0,barra50,Open);
#endif

   const uchar cantVelas=1; //cantidad de velas requeridas para el pATR_1on

   if((barra50+cantVelas)>(Bars(simbolo50,periodo50)))
     {
      Print("No shooting Star. No hay suficiente cantidad de velas.");
      return(false);
     }

   const double tamanoTotal=High[barra50]-Low[barra50];

   if(tamanoTotal==0)
     {
      Print("No shooting Star. maximo es igual a minimo.");
      return(false);
     }

   const double mechaInferior=(MathMin(Close[barra50],Open[barra50])-Low[barra50])/tamanoTotal;

   if(mechaInferior>mechaPequenai)
     {
      Print("No shooting Star. Mecha inferior es mayor a tamano requerido ("+DoubleToString(mechaInferior*100,2)+"% > "+
            DoubleToString(mechaPequenai*100,2)
            +"%).");
      return(false);
     }

   const double mechaSuperior=(High[barra50]-MathMax(Close[barra50],Open[barra50]))/tamanoTotal;

   if(mechaSuperior<mechaGrandotai)
     {
      Print("No shooting Star. Mecha superior es menor a tamano requerido ("+DoubleToString(mechaSuperior*100,2)+"% < "+
            DoubleToString(mechaGrandotai*100,2)
            +"%).");
      return(false);
     }

   Print("Es shooting star.");
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EnviarOrden(MqlTradeRequest &request,MqlTradeResult &result,const string tipoSend=NULL) export
  {
   if(obsoleto())
     {
      return false;
     }

   long digitos1;
   if(!SymbolInfoInteger(request.symbol,SYMBOL_DIGITS,digitos1))
     {
      Print("Error, validarStopLoss, digitos");
      ExpertRemove();
      return(false);
     }
   const int digitos=(int)digitos1;

   double bid;
   if(!SymbolInfoDouble(request.symbol,SYMBOL_BID,bid))
     {
      Print("Error, validarPrecioApertura, bid");
      ExpertRemove();
      return(false);
     }
   bid=NormalizeDouble(bid,digitos);

   double ask;
   if(!SymbolInfoDouble(request.symbol,SYMBOL_ASK,ask))
     {
      Print("Error, validarPrecioApertura, bid");
      ExpertRemove();
      return(false);
     }
   ask=NormalizeDouble(ask,digitos);

   long spread;
   if(!SymbolInfoInteger(request.symbol,SYMBOL_SPREAD,spread))
     {
      Print("Error, validarStopLoss, spread");
      ExpertRemove();
      return(false);
     }

   long stopLevel;
   if(!SymbolInfoInteger(request.symbol,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(request.symbol,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }
   puntos=NormalizeDouble(puntos,digitos);

   request.price=NormalizeDouble(request.price,(int)digitos);
   if(request.price<=0)
     {
      Print("precioApertura menor o igual a cero");
      ExpertRemove();
      return(false);
     }

   request.stoplimit=NormalizeDouble(request.stoplimit,(int)digitos);
   if(request.stoplimit<0)
     {
      Print("stoplimit negativo");
      ExpertRemove();
      return(false);
     }

   request.sl=NormalizeDouble(request.sl,(int)digitos);
   if(request.sl<0)
     {
      Print("StopLoss negativo");
      ExpertRemove();
      return(false);
     }

   request.tp=NormalizeDouble(request.tp,(int)digitos);
   if(request.tp<0)
     {
      Print("TakeProfit negativo");
      ExpertRemove();
      return(false);
     }

   if(request.action==TRADE_ACTION_DEAL)
     {
      if(tipoSend==NULL)
        {
         Print("Error tipoSend en blanco");
         ExpertRemove();
         return(false);
        }

      if(tipoSend=="abrir")
        {
           {//Calibrar lote

            //agregar lineas que midan si tengo el dinero suficiente para aperturar.
            double loteMinimo;
            if(!SymbolInfoDouble(request.symbol,SYMBOL_VOLUME_MIN,loteMinimo))
              {
               Print("Error, loteMinimo, puntos");
               ExpertRemove();
               return(false);
              }

            double loteMaximo;
            if(!SymbolInfoDouble(request.symbol,SYMBOL_VOLUME_MAX,loteMaximo))
              {
               Print("Error, loteMaximo, puntos");
               ExpertRemove();
               return(false);
              }

            if(request.volume>loteMaximo)
              {
               Print("volumen mayor al permitido "+(DoubleToString(request.volume)+" > "+DoubleToString(loteMaximo)));
               request.volume=loteMaximo;
               Print("Se disminuye volumen.");
              }

            request.volume=MathFloor(request.volume/loteMinimo)*loteMinimo;

            if(request.volume<=0)
              {
               Print("volumen menor o igual a cero");
               ExpertRemove();
               return(false);
              }
           }

         const long riesgoMinimo=spread+stopLevel;
         long riesgo;

         long beneficio;

         const long beneficioMinimo=spread+stopLevel;

         switch((int)request.type)
           {
            case LARGO_STOP:
              {
               if(request.price<(ask+stopLevel*puntos))
                 {
                  Print("Denegado precioApertura para posicionar BUY_STOP. Precio de apertura menos precio ask es inferior a stopLevel (("
                        +DoubleToString(request.type,digitos)+" - "+DoubleToString(ask,digitos)+") < "+DoubleToString(stopLevel,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.price-request.sl)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para posicionar BUY_STOP. Riesgo es menor a riesgo minimo aceptable (("+
                           DoubleToString(request.price,digitos)+" - "+DoubleToString(request.sl,digitos)+") < "
                           +DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               if(request.tp>0)
                 {
                  beneficio=(long)((request.tp-request.price)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para posicionar BUY_STOP. Beneficio es menor que beneficio minimo aceptable (("
                           +DoubleToString(request.tp,digitos)+" - "+DoubleToString(request.price,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            case LARGO_LIMIT:
              {
               if(request.price>(ask-stopLevel*puntos))
                 {
                  Print("Denegado precioApertura para posicionar BUY_LIMIT. Precio Ask menos precio de apertura es inferior a stopLevel (("
                        +DoubleToString(ask,digitos)+" - "+DoubleToString(request.type,digitos)+") < "+DoubleToString(stopLevel,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.price-request.sl)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para posicionar BUY_LIMIT. Riesgo es menor que riesgo minimo aceptable (("+
                           DoubleToString(request.price,digitos)+" - "+DoubleToString(request.sl,digitos)
                           +") < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               if(request.tp>0)
                 {
                  beneficio=(long)((request.tp-request.price)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para posicionar BUY_LIMIT. Beneficio es menor que beneficio minimo aceptable (("
                           +DoubleToString(request.tp,digitos)+" - "+DoubleToString(request.price,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            case LARGO:
              {
               if(request.price!=ask)
                 {
                  //aqui
                  Print("Denegado PrecioApertura para aperturar LARGO. PrecioApertura es diferente a Ask ("
                        +DoubleToString(request.price,digitos)+" != "+DoubleToString(ask,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.price-request.sl)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para aperturar LARGO. Riesgo es menor que riesgo minimo aceptable (("+
                           DoubleToString(request.price,digitos)+" - "+DoubleToString(request.sl,digitos)
                           +") < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               if(request.tp>0)
                 {
                  beneficio=(long)((request.tp-request.price)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para aperturar LARGO. Beneficio es menor que beneficio minimo aceptable (("+
                           DoubleToString(request.tp,digitos)+" - "+DoubleToString(request.price,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            case CORTO:
              {
               if(request.price!=bid)
                 {
                  Print("Denegado precioApertura para aperturar CORTO. PrecioApertura es diferente a precio Bid ("
                        +DoubleToString(request.type,digitos)+" != "+DoubleToString(ask,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.sl-request.price)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para aperturar CORTO. Riesgo es menor que riesgo minimo aceptable (("+
                           DoubleToString(request.sl,digitos)+" - "+DoubleToString(request.price,digitos)
                           +") < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }

               if(request.tp>0)
                 {
                  beneficio=(long)((request.price-request.tp)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para aperturar CORTO. Beneficio es menor que beneficio minimo aceptable (("+
                           DoubleToString(request.price,digitos)+" - "+DoubleToString(request.tp,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            case CORTO_LIMIT:
              {
               if(request.price<(bid+stopLevel*puntos))
                 {
                  Print("Denegado precio de apertura para posicionar SELL_LIMIT. Precio de apertura menos precio Bid es inferior a StopLevel (("
                        +DoubleToString(request.type,digitos)+" - "+DoubleToString(bid,digitos)+") < "+DoubleToString(stopLevel,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.sl-request.price)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para posicionar SELL_LIMIT. Riesgo es menor que riesgo minimo aceptable (("+
                           DoubleToString(request.sl,digitos)+" - "+DoubleToString(request.price,digitos)
                           +") < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               if(request.tp>0)
                 {
                  beneficio=(long)((request.price-request.tp)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para aperturar SELL_LIMIT. Beneficio es menor que beneficio minimo aceptable (("
                           +DoubleToString(request.price,digitos)+" - "+DoubleToString(request.tp,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            case CORTO_STOP:
              {
               if(request.price>(bid-stopLevel*puntos))
                 {
                  Print("Denegado precio de apertura para posicionar SELL_STOP. Precio Bid menos precio de apertura es inferior a StopLevel )("
                        +DoubleToString(bid,digitos)+" - "+DoubleToString(request.type,digitos)+") < "+DoubleToString(stopLevel,digitos)+").");
                  return(false);
                 }
               if(request.sl>0)
                 {
                  riesgo=(long)((request.sl-request.price)/puntos);
                  if(riesgo<riesgoMinimo)
                    {
                     Print("Denegado StopLoss para posicionar SELL_STOP. Riesgo es menor que riesgo minimo aceptable (("+
                           DoubleToString(request.sl,digitos)+" - "+DoubleToString(request.price,digitos)
                           +") < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               if(request.tp>0)
                 {
                  beneficio=(long)((request.price-request.tp)/puntos);
                  if(beneficio<beneficioMinimo)
                    {
                     Print("Denegado TakeProfit para aperturar SELL_STOP. Beneficio es menor que beneficio minimo aceptable (("
                           +DoubleToString(request.price,digitos)+" - "+DoubleToString(request.tp,digitos)+") < "+
                           DoubleToString(beneficioMinimo*puntos,digitos)+").");
                     return(false);
                    }
                 }
               break;
              }
            default:
              {
               Print("Error: Tipo de operacion indefinida");
               return(false);
              }
           }
        }
     }

   if(request.action==TRADE_ACTION_SLTP)
     {
      MqlTradeRequest DatosActuales={0};

#ifdef __MQL5__

      if(!PositionGetInteger(POSITION_TICKET,DatosActuales.position))
         return(false);
      if(!PositionGetString(POSITION_SYMBOL,DatosActuales.symbol))
         return(false);
      if(!PositionGetDouble(POSITION_SL,DatosActuales.sl))
         return(false);
      if(!PositionGetDouble(POSITION_TP,DatosActuales.tp))
         return(false);
      if(!PositionGetInteger(POSITION_MAGIC,DatosActuales.magic))
         return(false);
      if(!PositionGetDouble(POSITION_PRICE_OPEN,DatosActuales.price))
         return(false);
      if(!PositionGetDouble(POSITION_VOLUME,DatosActuales.volume))
         return(false);


#endif
#ifdef __MQL4__
      DatosActuales.price=NormalizeDouble(OrderOpenPrice(),digitos);
      DatosActuales.sl=NormalizeDouble(OrderStopLoss(),digitos);
      DatosActuales.tp=NormalizeDouble(OrderTakeProfit(),digitos);
      DatosActuales.expiration=OrderExpiration();
#endif


      if(((request.type==(ENUM_ORDER_TYPE)CORTO)) || ((request.type==(ENUM_ORDER_TYPE)LARGO)))
        {
         if((DatosActuales.price!=request.price) || (DatosActuales.expiration!=request.expiration))
           {
            Print("Error OrderModify intento de modificar expira o precio de apertura en ordenes abiertas");
            ExpertRemove();
            return(false);
           }
         if(
            (DatosActuales.sl==request.sl) &&
            (DatosActuales.tp==request.tp)
            )
           {
            return(false);
           }
        }

      if(((request.type==(ENUM_ORDER_TYPE)CORTO_LIMIT)) || ((request.type==(ENUM_ORDER_TYPE)LARGO_LIMIT)) ||
         ((request.type==(ENUM_ORDER_TYPE)CORTO_STOP)) || ((request.type==(ENUM_ORDER_TYPE)LARGO_STOP)))
        {
         if(
            (DatosActuales.sl==request.sl) &&
            (DatosActuales.tp==request.tp) &&
            (DatosActuales.expiration==request.expiration) && 
            (DatosActuales.price==request.price)
            )
           {
            return(false);
           }
        }

     }

#ifdef __MQL5__

   if(!OrderSend(request,result))
     {
      Print("Error orderSend "+IntegerToString(_LastError));
      ExpertRemove();
      return(false);
     }

#endif
#ifdef __MQL4__

   if(request.action==TRADE_ACTION_DEAL)
     {
      if(tipoSend=="abrir")
        {
         if(OrderSend(request.symbol,request.type,request.volume,request.price,
            request.deviation,request.sl,request.tp,request.comment,request.magic)==-1)
           {
            Print("Error orderSend "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }
        }

      if(tipoSend=="cerrar")
        {
         if(!OrderClose((int)request.position,request.volume,request.price,request.deviation))
           {
            Print("Error orderClose "+IntegerToString(_LastError));
            ExpertRemove();
            return(false);
           }
        }
     }

   if(request.action==TRADE_ACTION_SLTP)
     {
      if(!OrderModify((int)request.position,request.price,request.sl,request.tp,request.expiration))
        {
         Print("Error OrderModify "+IntegerToString(_LastError));

         ExpertRemove();
         return(false);
        }
     }
#endif
   return(true);
  }
//+------------------------------------------------------------------+

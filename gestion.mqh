//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property library
#property strict


#ifdef __MQL4__
#include "..\\Include_jf\\SymbolInfo.mqh"
#endif


#ifdef __MQL5__
#include <Trade\SymbolInfo.mqh>
#endif

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnumTipoOperacion
  {
#ifdef __MQL5__
   LARGO=ORDER_TYPE_BUY,
   CORTO=ORDER_TYPE_SELL,
   LARGO_STOP=ORDER_TYPE_BUY_STOP,
   CORTO_STOP=ORDER_TYPE_SELL_STOP,
   LARGO_LIMIT=ORDER_TYPE_BUY_LIMIT,
   CORTO_LIMIT=ORDER_TYPE_SELL_LIMIT,
   CUALQUIERA=10
#endif

#ifdef __MQL4__
              LARGO=OP_BUY,
              CORTO=OP_SELL,
              LARGO_STOP=OP_BUYSTOP,
              CORTO_STOP=OP_SELLSTOP,
              LARGO_LIMIT=OP_BUYLIMIT,
              CORTO_LIMIT=OP_SELLLIMIT,
              CUALQUIERA=10
#endif
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoGestion
  {
   LOTE_FIJO=0,
   FRACCION_FIJA=1,
   FRACCION_KELLY=2
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DineroTotal()
  {
   return(AccountInfoDouble(ACCOUNT_EQUITY));
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CalcularFraccionKelly(const int historicoBase,double& porcentaje1)
  {

#ifdef __MQL5__
   porcentaje1=0.01;
   Print("no se ha hecho el codigo para mt5"); //no se sabe como armar OrderProfit();
   return(false);
#endif

#ifdef __MQL4__
   double sumaAciertos=0.0;
   uint contAciertos=0.0;
   double sumaPerdida=0.0;
   uint contPerdidas=0.0;

   for(int cont=(OrdersHistoryTotal()-1-historicoBase); cont>=0; cont--)
     {
      if(OrderSelect(cont,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit()>0)
           {
            sumaAciertos=sumaAciertos+OrderProfit();
            contAciertos++;
           }
         if(OrderProfit()<0)
           {
            sumaPerdida=sumaPerdida+OrderProfit();
            contPerdidas++;
           }
        }
     }

   if((contPerdidas==0) || (contAciertos==0) || (sumaAciertos==0) || (sumaPerdida==0))
     {
      return(false);
     }

   double porcenAcierto=((double)contAciertos)/OrdersHistoryTotal();
   double promAcierto=sumaAciertos/((double)contAciertos);
   double promPerdida=sumaPerdida/((double)contPerdidas);

   porcentaje1=porcenAcierto-(1-porcenAcierto)/(promAcierto/MathAbs(promPerdida));

   if(porcentaje1<=0)
     {
      Print("Porcentaje negativo.");
      return(false);
     }

   return(true);
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Validar_precioApertura(const string _simbolo,const double _precioApertura,const EnumTipoOperacion tipoOperacion)
  {
   if(_precioApertura<=0)
     {
      Print("Precio Apertura menor o igual a cero");
      ExpertRemove();
      return(false);
     }

   long stopLevel1;
   if(!SymbolInfoInteger(_simbolo,SYMBOL_TRADE_STOPS_LEVEL,stopLevel1))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(_simbolo,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }
   const double stopLevel=stopLevel1*puntos;

   long digitos1;
   if(!SymbolInfoInteger(_simbolo,SYMBOL_DIGITS,digitos1))
     {
      Print("Error, validarStopLoss, digitos");
      ExpertRemove();
      return(false);
     }
   const int digits=(int)digitos1;

   double bid;
   if(!SymbolInfoDouble(_simbolo,SYMBOL_BID,bid))
     {
      Print("Error, validar_precioApertura, bid");
      ExpertRemove();
      return(false);
     }

   double ask;
   if(!SymbolInfoDouble(_simbolo,SYMBOL_ASK,ask))
     {
      Print("Error, validar_precioApertura, bid");
      ExpertRemove();
      return(false);
     }

   switch(tipoOperacion)
     {
      case LARGO:
        {
         if(_precioApertura!=ask)
           {
            Print("Denegado precio de apertura para aperturar LARGO. Precio de apertura es diferente a precio Ask ("
                  +DoubleToString(_precioApertura,digits)+" != "+DoubleToString(ask,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para aperturar LARGO.");
            return(true);
           }
        }
      case LARGO_STOP:
        {
         if(_precioApertura<(ask+stopLevel))
           {
            Print("Denegado precio de apertura para posicionar BUY_STOP. Precio de apertura menos precio ask es inferior a stopLevel ("
                  +DoubleToString(_precioApertura,digits)+" - "+DoubleToString(ask,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para posicionar BUY_STOP.");
            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         if(_precioApertura>(ask-stopLevel))
           {
            Print("Denegado precio de apertura para posicionar BUY_LIMIT. Precio Ask menos precio de apertura es inferior a stopLevel ("
                  +DoubleToString(ask,digits)+" - "+DoubleToString(_precioApertura,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para posicionar BUY_LIMIT.");
            return(true);
           }
        }
      case CORTO:
        {
         if(_precioApertura!=bid)
           {
            Print("Denegado precio de apertura para aperturar CORTO. Precio de apertura es diferente a precio Bid ("
                  +DoubleToString(_precioApertura,digits)+" != "+DoubleToString(ask,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para aperturar CORTO.");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         if(_precioApertura>(bid-stopLevel))
           {
            Print("Denegado precio de apertura para posicionar SELL_STOP. Precio Bid menos precio de apertura es inferior a StopLevel ("
                  +DoubleToString(bid,digits)+" - "+DoubleToString(_precioApertura,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para posicionar SELL_STOP.");
            return(true);
           }
        }
      case CORTO_LIMIT:
        {
         if(_precioApertura<(bid+stopLevel))
           {
            Print("Denegado precio de apertura para posicionar SELL_LIMIT. Precio de apertura menos precio Bid es inferior a StopLevel ("
                  +DoubleToString(_precioApertura,digits)+" - "+DoubleToString(bid,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(_precioApertura,digits)+" para posicionar SELL_LIMIT.");
            return(true);
           }
        }
      default:
        {
         Print("Error: Tipo de operacion indefinida");
         return(false);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidarTakeProfit(const double tp,const double _precioApertura,const string _simbolo,const ENUM_ORDER_TYPE tipoOperacion)
  {
   if(tp<0)
     {
      Print("TakeProfit negativo");
      ExpertRemove();
      return(false);
     }
   if(tp==0)
     {
      Print("TakeProfit cero.");
      return(true);
     }

   long spread;
   if(!SymbolInfoInteger(_simbolo,SYMBOL_SPREAD,spread))
     {
      Print("Error, validarStopLoss, spread");
      ExpertRemove();
      return(false);
     }

   long stopLevel;
   if(!SymbolInfoInteger(_simbolo,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(_simbolo,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }

   long digitos1;
   if(!SymbolInfoInteger(_simbolo,SYMBOL_DIGITS,digitos1))
     {
      Print("Error, validarStopLoss, digitos");
      ExpertRemove();
      return(false);
     }
   const int digitos=(int)digitos1;

   const long beneficioMinimo=spread+stopLevel;
   long beneficio;

   switch((int)tipoOperacion)
     {
      case LARGO_STOP:
        {
         beneficio=(long)((tp-_precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para posicionar BUY_STOP. TakeProfit menos Precio de apertura es menor que _riesgo minimo aceptable ("+
                  DoubleToString(tp,digitos)+" - "+DoubleToString(_precioApertura,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para posicionar BUY_STOP");
            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         beneficio=(long)((tp-_precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para posicionar BUY_LIMIT. TakeProfit menos Precio de apertura es menor que _riesgo minimo aceptable ("+
                  DoubleToString(tp,digitos)+" - "+DoubleToString(_precioApertura,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para posicionar BUY_LIMIT");
            return(true);
           }
        }
      case LARGO:
        {
         beneficio=(long)((tp-_precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar LARGO. TakeProfit menos Precio de apertura es menor que _riesgo minimo aceptable ("+
                  DoubleToString(tp,_Digits)+" - "+DoubleToString(_precioApertura,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para aperturar LARGO");
            return(true);
           }
        }
      case CORTO:
        {
         beneficio=(long)((_precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar CORTO. Precio de apertura menos TakeProfit es menor que _riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para aperturar CORTO");
            return(true);
           }
         break;
        }
      case CORTO_LIMIT:
        {
         beneficio=(long)((_precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar SELL_LIMIT. Precio de apertura menos TakeProfit es menor que _riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para posicionar SELL_LIMIT");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         beneficio=(long)((_precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado StopLoss para aperturar SELL_STOP. Precio de apertura menos TakeProfit es menor que _riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
                  DoubleToString(beneficioMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado TakeProfit en "+DoubleToString(tp,digitos)+" para posicionar SELL_STOP");
            return(true);
           }
        }
      default:
        {
         Print("Error: Tipo de operacion indefinida");
         return(false);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidarStopLoss(
   CSymbolInfo &_simbolo,
   const double _precioApertura,
   const double _sl,
   const ENUM_ORDER_TYPE tipoOperacion
)
  {
   if(_sl < 0)
     {
      Print("StopLoss negativo");
      ExpertRemove();
      return(false);
     }
   if(_sl == 0)
     {
      Print("StopLoss cero.");
      return(true);
     }

   const long _riesgoMinimo = _simbolo.Spread() + _simbolo.StopsLevel();
   long _riesgo;

   switch((int)tipoOperacion)
     {
      case LARGO_STOP:
        {
         _riesgo=(long)((_precioApertura - _sl) / _simbolo.Point());
         if(_riesgo<_riesgoMinimo)
           {

            Print(
               "Denegado StopLoss para posicionar BUY_STOP. Precio de apertura menos StopLoss es menor a _riesgo minimo aceptable (" +
               DoubleToString(_precioApertura, _simbolo.Digits()) + " - " +
               DoubleToString(_sl, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo * _simbolo.Point(), _simbolo.Digits()) +
               ")."
            );

            return(false);
           }
         else
           {

            Print(
               "Aceptado StopLoss en " + DoubleToString(_sl, _simbolo.Digits()) +
               " para posicionar BUY_STOP"
            );

            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         _riesgo=(long)((_precioApertura-_sl) / _simbolo.Point());
         if(_riesgo<_riesgoMinimo)
           {
            Print(
               "Denegado StopLoss para posicionar BUY_LIMIT. Precio de apertura menos StopLoss es menor que _riesgo minimo aceptable (" +
               DoubleToString(_precioApertura, _simbolo.Digits()) + " - " +
               DoubleToString(_sl, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo * _simbolo.Point(), _simbolo.Digits()) +
               ")."
            );

            return(false);
           }
         else
           {

            Print(
               "Aceptado StopLoss en " + DoubleToString(_sl, _simbolo.Digits()) +
               " para posicionar BUY_LIMIT"
            );

            return(true);
           }
        }
      case LARGO:
        {
         _riesgo=(long)((_precioApertura-_sl) / _simbolo.Point());
         if(_riesgo<_riesgoMinimo)
           {

            Print(
               "Denegado StopLoss para aperturar LARGO. Precio de apertura menos StopLoss es menor que _riesgo minimo aceptable (" +
               DoubleToString(_precioApertura, _simbolo.Digits())+" - " +
               DoubleToString(_sl, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo * _simbolo.Point(), _simbolo.Digits()) +
               ")."
            );

            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl, _simbolo.Digits())+" para posicionar LARGO");
            return(true);
           }
        }
      case CORTO:
        {
         _riesgo=(long)((_sl-_precioApertura) / _simbolo.Point());
         if(_riesgo<_riesgoMinimo)
           {

            Print(
               "Denegado StopLoss para aperturar CORTO. StopLoss menos Precio de apertura es menor que _riesgo minimo aceptable (" +
               DoubleToString(_sl, _simbolo.Digits()) + " - " +
               DoubleToString(_precioApertura, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo*_simbolo.Point(), _simbolo.Digits()) + ")."
            );

            return(false);

           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl, _simbolo.Digits())+" para posicionar CORTO");
            return(true);
           }
        }
      case CORTO_LIMIT:
        {

         _riesgo=(long)((_sl-_precioApertura) / _simbolo.Point());

         if(_riesgo<_riesgoMinimo)
           {

            Print(
               "Denegado StopLoss para posicionar SELL_LIMIT. StopLoss menos Precio de apertura es menor que _riesgo minimo aceptable (" +
               DoubleToString(_sl, _simbolo.Digits()) + " - " +
               DoubleToString(_precioApertura, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo * _simbolo.Point(), _simbolo.Digits()) + ")."
            );

            return(false);

           }
         else
           {
            Print("Aceptado StopLoss en " + DoubleToString(_sl, _simbolo.Digits()) + " para posicionar SELL_LIMIT");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         _riesgo=(long)((_sl-_precioApertura) / _simbolo.Point());
         if(_riesgo<_riesgoMinimo)
           {

            Print(
               "Denegado StopLoss para posicionar SELL_STOP. StopLoss menos Precio de apertura es menor que _riesgo minimo aceptable (" +
               DoubleToString(_sl, _simbolo.Digits()) + " - " +
               DoubleToString(_precioApertura, _simbolo.Digits()) + " < " +
               DoubleToString(_riesgoMinimo * _simbolo.Point(), _simbolo.Digits()) + ")."
            );

            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en " + DoubleToString(_sl, _simbolo.Digits()) + " para posicionar SELL_STOP");
            return(true);
           }
        }
      default:
        {
         Print("Error: Tipo de operacion indefinida");
         return(false);
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ReducirLote(
   CSymbolInfo &_simbolo,
   double _lote,
   double _Maximum_Lots = 999999999999999
)
  {

   _lote = MathMin(_lote, _simbolo.LotsMax());

   _lote = MathMin(_lote, _Maximum_Lots);

   return _lote;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AumentarLote(
   CSymbolInfo &_simbolo,
   double _lote,
   double _Minimum_Lots = 0
)
  {

   _lote = MathMax(_lote, _simbolo.LotsMin());

   _lote = MathMax(_lote, _Minimum_Lots);

   return _lote;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizarLote(CSymbolInfo &_simbolo, const double _lote)
  {

   return MathFloor(_lote / _simbolo.LotsStep()) * _simbolo.LotsStep();

  }


#ifdef __MQL5__

//+------------------------------------------------------------------+
//| hay que dividirlo entre cien en la entrada                       |
//| sl no puede ser 0                                                |
//+------------------------------------------------------------------+
bool CalcularLoteUsandoFraccion(
   const ENUM_ORDER_TYPE _tipoPosicion,
   string _simbolo,
   const double _apertura,
   const double _sl,
   const double _riesgo,
   const double _balance,
   double& _lote
)
  {

   double _profit;

   if(!OrderCalcProfit(
         _tipoPosicion,
         _simbolo,
         1,
         _apertura,
         _sl,
         _profit
      ))
     {
      Print("!OrderCalcProfit");
      return false;
     }

   _lote = (_balance * _riesgo) / (-_profit);

   return true;

  }

#endif


#ifdef __MQL4__
double QNaN=(double)"nan";   // QNaN
//+------------------------------------------------------------------+
//| Computes the mean value of the values in array[]                 |
//+------------------------------------------------------------------+
double MathMean(const double& array[])
  {
   int size=ArraySize(array);
//--- check data range
   if(size<1)
      return(QNaN); // need at least 1 observation
//--- calculate mean
   double mean=0.0;
   for(int i=0; i<size; i++)
      mean+=array[i];
   mean=mean/size;
//--- return mean
   return(mean);
  }

//+------------------------------------------------------------------+
//| Computes the standard deviation of the values in array[]         |
//+------------------------------------------------------------------+
double MathStandardDeviation(const double& array[])
  {
   int size=ArraySize(array);
   if(size<=1)
      return(QNaN);
//--- calculate mean
   double mean=0.0;
   for(int i=0; i<size; i++)
      mean+=array[i];
//--- average mean
   mean=mean/size;
//--- calculate standard deviation
   double sdev=0;
   for(int i=0; i<size; i++)
      sdev+=MathPow(array[i]-mean,2);
//--- return standard deviation
   return MathSqrt(sdev/(size-1));
  }

#endif
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

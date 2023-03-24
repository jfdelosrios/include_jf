//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property library
#property strict
#include  "..\Include\comunes17ago2018.mqh"
#include  "..\Include\gestion17ago2018.mqh"
#include "..\Include\SymbolInfo.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool obsoleto() export
  {
   if(TimeCurrent() >= D'2024.01.01 00:00')
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
double DineroTotal() export
  {
   return(AccountInfoDouble(ACCOUNT_EQUITY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CalcularFraccionKelly(const int historicoBase,double &porcentaje1) export
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
bool ValidarPrecioApertura(const string simbolo,const double precioApertura,const EnumTipoOperacion tipoOperacion) export
  {
   if(precioApertura<=0)
     {
      Print("Precio Apertura menor o igual a cero");
      ExpertRemove();
      return(false);
     }

   long stopLevel1;
   if(!SymbolInfoInteger(simbolo,SYMBOL_TRADE_STOPS_LEVEL,stopLevel1))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(simbolo,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }
   const double stopLevel=stopLevel1*puntos;

   long digitos1;
   if(!SymbolInfoInteger(simbolo,SYMBOL_DIGITS,digitos1))
     {
      Print("Error, validarStopLoss, digitos");
      ExpertRemove();
      return(false);
     }
   const int digits=(int)digitos1;

   double bid;
   if(!SymbolInfoDouble(simbolo,SYMBOL_BID,bid))
     {
      Print("Error, validarPrecioApertura, bid");
      ExpertRemove();
      return(false);
     }

   double ask;
   if(!SymbolInfoDouble(simbolo,SYMBOL_ASK,ask))
     {
      Print("Error, validarPrecioApertura, bid");
      ExpertRemove();
      return(false);
     }

   switch(tipoOperacion)
     {
      case LARGO:
        {
         if(precioApertura!=ask)
           {
            Print("Denegado precio de apertura para aperturar LARGO. Precio de apertura es diferente a precio Ask ("
                  +DoubleToString(precioApertura,digits)+" != "+DoubleToString(ask,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para aperturar LARGO.");
            return(true);
           }
        }
      case LARGO_STOP:
        {
         if(precioApertura<(ask+stopLevel))
           {
            Print("Denegado precio de apertura para posicionar BUY_STOP. Precio de apertura menos precio ask es inferior a stopLevel ("
                  +DoubleToString(precioApertura,digits)+" - "+DoubleToString(ask,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para posicionar BUY_STOP.");
            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         if(precioApertura>(ask-stopLevel))
           {
            Print("Denegado precio de apertura para posicionar BUY_LIMIT. Precio Ask menos precio de apertura es inferior a stopLevel ("
                  +DoubleToString(ask,digits)+" - "+DoubleToString(precioApertura,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para posicionar BUY_LIMIT.");
            return(true);
           }
        }
      case CORTO:
        {
         if(precioApertura!=bid)
           {
            Print("Denegado precio de apertura para aperturar CORTO. Precio de apertura es diferente a precio Bid ("
                  +DoubleToString(precioApertura,digits)+" != "+DoubleToString(ask,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para aperturar CORTO.");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         if(precioApertura>(bid-stopLevel))
           {
            Print("Denegado precio de apertura para posicionar SELL_STOP. Precio Bid menos precio de apertura es inferior a StopLevel ("
                  +DoubleToString(bid,digits)+" - "+DoubleToString(precioApertura,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para posicionar SELL_STOP.");
            return(true);
           }
        }
      case CORTO_LIMIT:
        {
         if(precioApertura<(bid+stopLevel))
           {
            Print("Denegado precio de apertura para posicionar SELL_LIMIT. Precio de apertura menos precio Bid es inferior a StopLevel ("
                  +DoubleToString(precioApertura,digits)+" - "+DoubleToString(bid,digits)+" < "+DoubleToString(stopLevel,digits)+").");
            return(false);
           }
         else
           {
            Print("Aceptado precio de apertura en "+DoubleToString(precioApertura,digits)+" para posicionar SELL_LIMIT.");
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
bool ValidarTakeProfit(const double tp,const double precioApertura,const string simbolo,const ENUM_ORDER_TYPE tipoOperacion) export
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
   if(!SymbolInfoInteger(simbolo,SYMBOL_SPREAD,spread))
     {
      Print("Error, validarStopLoss, spread");
      ExpertRemove();
      return(false);
     }

   long stopLevel;
   if(!SymbolInfoInteger(simbolo,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(simbolo,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }

   long digitos1;
   if(!SymbolInfoInteger(simbolo,SYMBOL_DIGITS,digitos1))
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
         beneficio=(long)((tp-precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para posicionar BUY_STOP. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(tp,digitos)+" - "+DoubleToString(precioApertura,digitos)+" < "+
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
         beneficio=(long)((tp-precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para posicionar BUY_LIMIT. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(tp,digitos)+" - "+DoubleToString(precioApertura,digitos)+" < "+
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
         beneficio=(long)((tp-precioApertura)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar LARGO. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(tp,_Digits)+" - "+DoubleToString(precioApertura,digitos)+" < "+
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
         beneficio=(long)((precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar CORTO. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
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
         beneficio=(long)((precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado TakeProfit para aperturar SELL_LIMIT. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
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
         beneficio=(long)((precioApertura-tp)/puntos);
         if(beneficio<beneficioMinimo)
           {
            Print("Denegado StopLoss para aperturar SELL_STOP. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(tp,digitos)+" < "+
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
bool ValidarStopLoss(const string simbolo,const double precioApertura,const double sl_1,const ENUM_ORDER_TYPE tipoOperacion) export
  {
   if(sl_1<0)
     {
      Print("StopLoss negativo");
      ExpertRemove();
      return(false);
     }
   if(sl_1==0)
     {
      Print("StopLoss cero.");
      return(true);
     }

   long spread;
   if(!SymbolInfoInteger(simbolo,SYMBOL_SPREAD,spread))
     {
      Print("Error, validarStopLoss, spread");
      ExpertRemove();
      return(false);
     }

   long stopLevel;
   if(!SymbolInfoInteger(simbolo,SYMBOL_TRADE_STOPS_LEVEL,stopLevel))
     {
      Print("Error, validarStopLoss, stopLevel");
      ExpertRemove();
      return(false);
     }

   double puntos;
   if(!SymbolInfoDouble(simbolo,SYMBOL_POINT,puntos))
     {
      Print("Error, validarStopLoss, puntos");
      ExpertRemove();
      return(false);
     }

   long digitos1;
   if(!SymbolInfoInteger(simbolo,SYMBOL_DIGITS,digitos1))
     {
      Print("Error, validarStopLoss, digitos");
      ExpertRemove();
      return(false);
     }
   const int digitos=(int)digitos1;

   const long riesgoMinimo=spread+stopLevel;
   long riesgo;

   switch((int)tipoOperacion)
     {
      case LARGO_STOP:
        {
         riesgo=(long)((precioApertura-sl_1)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar BUY_STOP. Precio de apertura menos StopLoss es menor a riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(sl_1,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar BUY_STOP");
            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         riesgo=(long)((precioApertura-sl_1)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar BUY_LIMIT. Precio de apertura menos StopLoss es menor que riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(sl_1,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar BUY_LIMIT");
            return(true);
           }
        }
      case LARGO:
        {
         riesgo=(long)((precioApertura-sl_1)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para aperturar LARGO. Precio de apertura menos StopLoss es menor que riesgo minimo aceptable ("+
                  DoubleToString(precioApertura,digitos)+" - "+DoubleToString(sl_1,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar LARGO");
            return(true);
           }
        }
      case CORTO:
        {
         riesgo=(long)((sl_1-precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para aperturar CORTO. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(sl_1,digitos)+" - "+DoubleToString(precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar CORTO");
            return(true);
           }
        }
      case CORTO_LIMIT:
        {
         riesgo=(long)((sl_1-precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar SELL_LIMIT. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(sl_1,digitos)+" - "+DoubleToString(precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar SELL_LIMIT");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         riesgo=(long)((sl_1-precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar SELL_STOP. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(sl_1,digitos)+" - "+DoubleToString(precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(sl_1,digitos)+" para posicionar SELL_STOP");
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
bool BuscarSimboloPuente(
   const string simboloOperado,
   const bool imprimirMensaje,
   string &simboloPuente
) export
  {

//depronto queda mejor si fuera una funcion recursiva
   simboloPuente="";
   const string monedaCotizada=SymbolInfoString(simboloOperado,SYMBOL_CURRENCY_PROFIT);
   const string monedaCuenta=AccountInfoString(ACCOUNT_CURRENCY);

   string monedaBasePuente="";
   string monedaCotizadaPuente="";
   for(int cont=(SymbolsTotal(false)-1); cont>=0; cont--)
     {
      monedaBasePuente=SymbolInfoString(SymbolName(cont,false),SYMBOL_CURRENCY_BASE);
      monedaCotizadaPuente=SymbolInfoString(SymbolName(cont,false),SYMBOL_CURRENCY_PROFIT);

      if(((monedaBasePuente==monedaCotizada) && (monedaCotizadaPuente==monedaCuenta)) ||
         ((monedaBasePuente==monedaCuenta) && (monedaCotizadaPuente==monedaCotizada)))
        {
         simboloPuente=monedaBasePuente+monedaCotizadaPuente;
         return(true);
        }
     }

   if(simboloPuente=="")
     {

      if(imprimirMensaje)
         Print("error: No existe simbolo que ayude a la conversion");

      return(false);
     }
   else
      return(true);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReducirLote(
   const string simbolo,
   double &loteSalida,
   double _Maximum_Lots = 999999999999999
) export
  {

   if(obsoleto())
      return false;

   loteSalida = MathMin(loteSalida, SymbolInfoDouble(simbolo, SYMBOL_VOLUME_MAX));

   loteSalida = MathMin(loteSalida, _Maximum_Lots);

   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AumentarLote(
   const string simbolo,
   double &loteSalida,
   double _Minimum_Lots = 0
) export
  {

   if(obsoleto())
      return false;

   loteSalida = MathMax(loteSalida, SymbolInfoDouble(simbolo, SYMBOL_VOLUME_MIN));

   loteSalida = MathMax(loteSalida, _Minimum_Lots);

   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NormalizarLote(const string simbolo,double &loteSalida) export
  {
  
   if(obsoleto())
      return false;
      
   double loteMinimo;

   if(!SymbolInfoDouble(simbolo,SYMBOL_VOLUME_MIN,loteMinimo))
     {
      return false;
     }

   loteSalida=MathFloor(loteSalida/loteMinimo)*loteMinimo;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizarLote(CSymbolInfo &m_symbol_1,double &loteEntrada12) export
  {
   if(obsoleto())
      return false;
   return MathFloor(loteEntrada12/m_symbol_1.LotsStep())*m_symbol_1.LotsStep();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
bool  CalcularLoteUsandoFraccion(
   double &loteSalida,
   const ENUM_ORDER_TYPE tipoOperacion3,
   const double precioApertura,
   const double sl_1,
   const double fraccion2,
   const string simbolo
) export
  {

   loteSalida=-1;

   if(obsoleto())
      return false;

   const string monedaCuenta=AccountInfoString(ACCOUNT_CURRENCY);

   if(monedaCuenta == "")
     {
      Print("Se desconoce moneda de la cuenta.");
      return(false);
     }

//OrderCheck(
// OrderCalcProfit(
//OrderCalcMargin(
//detecta precio de apertura

//preguntar en XM cual es la unidad de los puntos de swap

   if((tipoOperacion3 != ORDER_TYPE_BUY) && (tipoOperacion3 != ORDER_TYPE_SELL))
     {
      Print("Tipo de posicion no reconocida. Funcion " + __FUNCTION__);
      return false;
     }

   double riesgo=-1;

   if(tipoOperacion3 == ORDER_TYPE_BUY)
      riesgo = precioApertura - sl_1;

   if(tipoOperacion3 == ORDER_TYPE_SELL)
      riesgo = sl_1 - precioApertura;

   if(riesgo < 0)
     {
      Print("stopLoss o preciode de apertura mal puestos. Funcion " + __FUNCTION__);
      return(false);
     }

   const string monedaBase=SymbolInfoString(simbolo,SYMBOL_CURRENCY_BASE);
   const string monedaCotizada=SymbolInfoString(simbolo,SYMBOL_CURRENCY_PROFIT);

   /*
      if(monedaBase==monedaCotizada)//indice
        {
         Print("Indice, pendiente por programar");
         return(false);
        }
        */

   loteSalida=fraccion2*DineroTotal()*(1/riesgo)*(1/(SymbolInfoDouble(simbolo,SYMBOL_TRADE_CONTRACT_SIZE)));

   if(monedaCuenta!=monedaCotizada)
     {
      string simboloPuente;


      if(MQLInfoInteger(MQL_TESTER))
        {

         if(!BuscarSimboloPuente(simbolo, false, simboloPuente))
           {
            return(true);
           }
        }
      else
        {

         if(!BuscarSimboloPuente(simbolo, true, simboloPuente))
           {
            return(false);
           }

        }

      const string monedaBaseOperada=SymbolInfoString(simbolo,SYMBOL_CURRENCY_BASE);
      const string monedaCotizadaOperada=SymbolInfoString(simbolo,SYMBOL_CURRENCY_PROFIT);
      const string monedaBasePuente=SymbolInfoString(simboloPuente,SYMBOL_CURRENCY_BASE);
      const string monedaCotizadaPuente=SymbolInfoString(simboloPuente,SYMBOL_CURRENCY_PROFIT);

      const double bidOperado=SymbolInfoDouble(simbolo,SYMBOL_BID);
      const double askOperado=SymbolInfoDouble(simbolo,SYMBOL_ASK);
      const double bidPuente=SymbolInfoDouble(simboloPuente,SYMBOL_BID);
      const double askPuente=SymbolInfoDouble(simboloPuente,SYMBOL_ASK);

      if(monedaBasePuente==monedaCotizadaOperada)
        {

         if(tipoOperacion3 == ORDER_TYPE_BUY)
           {
            loteSalida=loteSalida/bidPuente;
           }

         if(tipoOperacion3 == ORDER_TYPE_SELL)
           {
            loteSalida=loteSalida/askPuente;
           }
        }

      if(monedaBasePuente==monedaBaseOperada)
        {
         if(tipoOperacion3 == ORDER_TYPE_BUY)
           {
            loteSalida=loteSalida*bidPuente;
           }

         if(tipoOperacion3 == ORDER_TYPE_SELL)
           {
            loteSalida=loteSalida*askPuente;
           }
        }
     }

   return true;

  }
//+------------------------------------------------------------------+


#ifdef __MQL4__
double QNaN=(double)"nan";   // QNaN
//+------------------------------------------------------------------+
//| Computes the mean value of the values in array[]                 |
//+------------------------------------------------------------------+
double MathMean(const double &array[])
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
double MathStandardDeviation(const double &array[])
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

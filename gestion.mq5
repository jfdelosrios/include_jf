//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property library
#property strict
#include  "..\Include_jf\comunes.mqh"
#include "..\Include_jf\SymbolInfo.mqh"


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
bool CalcularFraccionKelly(const int historicoBase,double& porcentaje1) export
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
bool Validar_precioApertura(const string _simbolo,const double _precioApertura,const EnumTipoOperacion tipoOperacion) export
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
bool ValidarTakeProfit(const double tp,const double _precioApertura,const string _simbolo,const ENUM_ORDER_TYPE tipoOperacion) export
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
            Print("Denegado TakeProfit para posicionar BUY_STOP. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
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
            Print("Denegado TakeProfit para posicionar BUY_LIMIT. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
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
            Print("Denegado TakeProfit para aperturar LARGO. TakeProfit menos Precio de apertura es menor que riesgo minimo aceptable ("+
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
            Print("Denegado TakeProfit para aperturar CORTO. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
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
            Print("Denegado TakeProfit para aperturar SELL_LIMIT. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
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
            Print("Denegado StopLoss para aperturar SELL_STOP. Precio de apertura menos TakeProfit es menor que riesgo minimo aceptable ("+
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
bool ValidarStopLoss(const string _simbolo,const double _precioApertura,const double _sl,const ENUM_ORDER_TYPE tipoOperacion) export
  {
   if(_sl<0)
     {
      Print("StopLoss negativo");
      ExpertRemove();
      return(false);
     }
   if(_sl==0)
     {
      Print("StopLoss cero.");
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

   const long riesgoMinimo=spread+stopLevel;
   long riesgo;

   switch((int)tipoOperacion)
     {
      case LARGO_STOP:
        {
         riesgo=(long)((_precioApertura-_sl)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar BUY_STOP. Precio de apertura menos StopLoss es menor a riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(_sl,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar BUY_STOP");
            return(true);
           }
        }
      case LARGO_LIMIT:
        {
         riesgo=(long)((_precioApertura-_sl)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar BUY_LIMIT. Precio de apertura menos StopLoss es menor que riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(_sl,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar BUY_LIMIT");
            return(true);
           }
        }
      case LARGO:
        {
         riesgo=(long)((_precioApertura-_sl)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para aperturar LARGO. Precio de apertura menos StopLoss es menor que riesgo minimo aceptable ("+
                  DoubleToString(_precioApertura,digitos)+" - "+DoubleToString(_sl,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar LARGO");
            return(true);
           }
        }
      case CORTO:
        {
         riesgo=(long)((_sl-_precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para aperturar CORTO. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(_sl,digitos)+" - "+DoubleToString(_precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar CORTO");
            return(true);
           }
        }
      case CORTO_LIMIT:
        {
         riesgo=(long)((_sl-_precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar SELL_LIMIT. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(_sl,digitos)+" - "+DoubleToString(_precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar SELL_LIMIT");
            return(true);
           }
        }
      case CORTO_STOP:
        {
         riesgo=(long)((_sl-_precioApertura)/puntos);
         if(riesgo<riesgoMinimo)
           {
            Print("Denegado StopLoss para posicionar SELL_STOP. StopLoss menos Precio de apertura es menor que riesgo minimo aceptable ("+
                  DoubleToString(_sl,digitos)+" - "+DoubleToString(_precioApertura,digitos)+" < "+DoubleToString(riesgoMinimo*puntos,digitos)+").");
            return(false);
           }
         else
           {
            Print("Aceptado StopLoss en "+DoubleToString(_sl,digitos)+" para posicionar SELL_STOP");
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
bool Buscar_simboloPuente(
   const string _simboloOperado,
   const bool imprimirMensaje,
   string &_simboloPuente
) export
  {

//depronto queda mejor si fuera una funcion recursiva
   _simboloPuente="";
   const string monedaCotizada=SymbolInfoString(_simboloOperado,SYMBOL_CURRENCY_PROFIT);
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
         _simboloPuente=monedaBasePuente+monedaCotizadaPuente;
         return(true);
        }
     }

   if(_simboloPuente=="")
     {

      if(imprimirMensaje)
         Print("error: No existe _simbolo que ayude a la conversion");

      return(false);
     }
   else
      return(true);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReducirLote(
   const string _simbolo,
   double& _lote,
   double _Maximum_Lots = 999999999999999
) export
  {

   if(obsoleto())
      return false;

   _lote = MathMin(_lote, SymbolInfoDouble(_simbolo, SYMBOL_VOLUME_MAX));

   _lote = MathMin(_lote, _Maximum_Lots);

   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AumentarLote(
   const string _simbolo,
   double& _lote,
   double _Minimum_Lots = 0
) export
  {

   if(obsoleto())
      return false;

   _lote = MathMax(_lote, SymbolInfoDouble(_simbolo, SYMBOL_VOLUME_MIN));

   _lote = MathMax(_lote, _Minimum_Lots);

   return(true);
   
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizarLote(CSymbolInfo &m_simbolo, double& _lote) export
  {
  
   if(obsoleto())
      return false;
      
   return MathFloor(_lote / m_simbolo.LotsStep()) * m_simbolo.LotsStep();
   
  }


#ifdef __MQL5__

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CalcularLoteUsandoFraccion(
   const ENUM_ORDER_TYPE _tipoPosicion,
   CSymbolInfo &m_simbolo,
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
         m_simbolo.Name(),
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
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
bool  CalcularLoteUsandoFraccion(
   double& _lote,
   const ENUM_ORDER_TYPE _tipoPosicion,
   const double _precioApertura,
   const double _sl,
   const double _fraccion,
   const string _simbolo
) export
  {

// lotes = (porcentaje_riesgo/100) * (AccountInfoDouble(ACCOUNT_BALANCE)-commision)/((_SL_temp/P)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE))/P;

   _lote=-1;

   if(obsoleto())
      return false;

   const string monedaCuenta=AccountInfoString(ACCOUNT_CURRENCY);

   if(monedaCuenta == "")
     {
      Print("Se desconoce moneda de la cuenta.");
      return(false);
     }

   if((_tipoPosicion != ORDER_TYPE_BUY) && (_tipoPosicion != ORDER_TYPE_SELL))
     {
      Print("Tipo de posicion no reconocida. Funcion " + __FUNCTION__);
      return false;
     }

   double riesgo=-1;

   if(_tipoPosicion == ORDER_TYPE_BUY)
      riesgo = _precioApertura - _sl;

   if(_tipoPosicion == ORDER_TYPE_SELL)
      riesgo = _sl - _precioApertura;

   if(riesgo < 0)
     {
      Print("stopLoss o preciode de apertura mal puestos. Funcion " + __FUNCTION__);
      return(false);
     }

   const string monedaBase=SymbolInfoString(_simbolo,SYMBOL_CURRENCY_BASE);
   const string monedaCotizada=SymbolInfoString(_simbolo,SYMBOL_CURRENCY_PROFIT);

   /*
      if(monedaBase==monedaCotizada)//indice
        {
         Print("Indice, pendiente por programar");
         return(false);
        }
        */

   _lote=_fraccion*DineroTotal()*(1/riesgo)*(1/(SymbolInfoDouble(_simbolo,SYMBOL_TRADE_CONTRACT_SIZE)));

   if(monedaCuenta!=monedaCotizada)
     {
      string _simboloPuente;


      if(MQLInfoInteger(MQL_TESTER))
        {

         if(!Buscar_simboloPuente(_simbolo, false, _simboloPuente))
           {
            return(true);
           }
        }
      else
        {

         if(!Buscar_simboloPuente(_simbolo, true, _simboloPuente))
           {
            return(false);
           }

        }

      const string monedaBaseOperada=SymbolInfoString(_simbolo,SYMBOL_CURRENCY_BASE);
      const string monedaCotizadaOperada=SymbolInfoString(_simbolo,SYMBOL_CURRENCY_PROFIT);
      const string monedaBasePuente=SymbolInfoString(_simboloPuente,SYMBOL_CURRENCY_BASE);
      const string monedaCotizadaPuente=SymbolInfoString(_simboloPuente,SYMBOL_CURRENCY_PROFIT);

      const double bidOperado=SymbolInfoDouble(_simbolo,SYMBOL_BID);
      const double askOperado=SymbolInfoDouble(_simbolo,SYMBOL_ASK);
      const double bidPuente=SymbolInfoDouble(_simboloPuente,SYMBOL_BID);
      const double askPuente=SymbolInfoDouble(_simboloPuente,SYMBOL_ASK);

      if(monedaBasePuente==monedaCotizadaOperada)
        {

         if(_tipoPosicion == ORDER_TYPE_BUY)
           {
            _lote=_lote/bidPuente;
           }

         if(_tipoPosicion == ORDER_TYPE_SELL)
           {
            _lote=_lote/askPuente;
           }
        }

      if(monedaBasePuente==monedaBaseOperada)
        {
         if(_tipoPosicion == ORDER_TYPE_BUY)
           {
            _lote=_lote*bidPuente;
           }

         if(_tipoPosicion == ORDER_TYPE_SELL)
           {
            _lote=_lote*askPuente;
           }
        }
     }

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

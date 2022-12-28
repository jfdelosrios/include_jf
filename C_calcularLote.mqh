//+------------------------------------------------------------------+
//|                                               C_calcularLote.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "..\\Include_jf\\SymbolInfo.mqh"

enum ENUM_OPERACION
  {
   multiplicacion,
   division
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_calcularLote
  {
private:

   double            m_lote;
   ENUM_OPERACION    i_tipoOperacion;
   string            m_monedaCuenta;

   CSymbolInfo       m_simboloPrincipal;
   CSymbolInfo       m_simboloPuente;

public:
                     C_calcularLote();
                    ~C_calcularLote();

   bool              Create(
      const string _simboloPrincipal,
      const ENUM_OPERACION _tipoOperacion
   );

   bool              CalcularLoteUsandoFraccion(
      const ENUM_ORDER_TYPE _tipoPosicion,
      const double _precioApertura,
      const double _sl,
      const double _fraccion,
      const double _balance,
      double& _lote,
      int _puntosPuente = 0
   );

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_calcularLote::C_calcularLote()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_calcularLote::~C_calcularLote()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_calcularLote::Create(
   const string _simboloPrincipal,
   const ENUM_OPERACION _tipoOperacion
)
  {

   m_lote = -1;

   if(!m_simboloPrincipal.Name(_simboloPrincipal))
     {
      Print("!m_simboloPrincipal.Name(_simboloPrincipal)");
      return false;
     }

   m_monedaCuenta = AccountInfoString(ACCOUNT_CURRENCY);

   if(m_monedaCuenta == "")
     {
      Print("Se desconoce moneda de la cuenta.");
      return(false);
     }

   i_tipoOperacion = _tipoOperacion;

   if(DetectarSimboloPuente(
         m_monedaCuenta,
         m_simboloPrincipal,
         m_simboloPuente
      ))
     {

      if(m_simboloPuente.CurrencyProfit() == m_monedaCuenta)
         i_tipoOperacion = division;

      if(m_simboloPuente.CurrencyBase() == m_monedaCuenta)
         i_tipoOperacion = multiplicacion;

     }


   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  C_calcularLote::CalcularLoteUsandoFraccion(
   const ENUM_ORDER_TYPE _tipoPosicion,
   const double _precioApertura,
   const double _sl,
   const double _fraccion,
   const double _balance,
   double& _lote,
   int _puntosPuente = 0
)
  {

   _lote = -1;

   if((_tipoPosicion != ORDER_TYPE_BUY) && (_tipoPosicion != ORDER_TYPE_SELL))
     {
      Print("Tipo de posicion no reconocida. Funcion " + __FUNCTION__);
      return false;
     }

   double _riesgo = -1;
   if(_tipoPosicion == ORDER_TYPE_BUY)
      _riesgo = _precioApertura - _sl;
   if(_tipoPosicion == ORDER_TYPE_SELL)
      _riesgo = _sl - _precioApertura;
   if(_riesgo < 0)
     {
      Print("stopLoss o precio de apertura mal puestos. Funcion " + __FUNCTION__);
      return false;
     }

   _lote = (_fraccion * _balance) * (1 / _riesgo) * (1 / m_simboloPrincipal.ContractSize());

   if(m_simboloPrincipal.CurrencyProfit() == m_monedaCuenta)
      return true;

   if(m_simboloPuente.Name() == m_simboloPrincipal.Name())
     {
      _lote = _lote * _sl;
      return true;
     }

   double _TickValue = -1; // precio actual del simbolo puente
   if(m_simboloPuente.Name() == "")
     {

      if(!MQLInfoInteger(MQL_TESTER))
        {
         Print("extrano que ingrese aqui");
        }

      m_simboloPrincipal.RefreshRates();
      _TickValue = m_simboloPrincipal.TickValue(); // bid  del simbolo puente, si es 1 no existe simbolo puente.

     }
   else
     {

      m_simboloPuente.RefreshRates();

      if(_tipoPosicion == ORDER_TYPE_BUY)
         _TickValue = m_simboloPuente.Bid();

      if(_tipoPosicion == ORDER_TYPE_SELL)
         _TickValue = m_simboloPuente.Ask();

     }

   double _slPuente = -1;
   if(_tipoPosicion == ORDER_TYPE_BUY)
      _slPuente = _TickValue - _puntosPuente;
   if(_tipoPosicion == ORDER_TYPE_SELL)
      _slPuente = _TickValue + _puntosPuente;

   double productoPuente;
   if(i_tipoOperacion == multiplicacion)
      productoPuente = _slPuente;
   else
      productoPuente = 1.0 / _slPuente;

   _lote = _lote * productoPuente;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DetectarSimboloPuente(
   const string m_monedaCuenta,
   CSymbolInfo &_simboloPrincipal,
   CSymbolInfo &_simboloPuente
)
  {

   if(_simboloPuente.Name(_simboloPrincipal.CurrencyProfit() + m_monedaCuenta))
     {
      return true;
     }

   if(_LastError == ERR_UNKNOWN_SYMBOL)
     {
      ResetLastError();
     }

   if(_simboloPuente.Name(m_monedaCuenta + _simboloPrincipal.CurrencyProfit()))
     {
      return true;
     }

   if(_LastError == ERR_UNKNOWN_SYMBOL)
     {
      ResetLastError();
     }

   return false;

  }
//+------------------------------------------------------------------+

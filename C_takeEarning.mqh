//+------------------------------------------------------------------+
//|                                                C_takeEarning.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "varios.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_takeEarning
  {
private:

   bool              i_activarObjetivo;
   double            i_objetivo;
   ulong             i_deslizamiento;
   posicionPropia    i_posicion[];

   double            m_balanceInicial;
   double            m_ganancia;
   bool              m_cicloActivado;
   bool              m_objetivoAlcanzado;

public:
                     C_takeEarning();
                    ~C_takeEarning();

   bool              Create(
      const bool _activarObjetivo,
      const double _objetivo,
      const ulong _deslizamiento,

      posicionPropia& _posicion[]
   );

   void              inicializar();

   bool              IntentarCerrar();

   bool              get_cicloActivado() { return m_cicloActivado; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_takeEarning::C_takeEarning()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_takeEarning::~C_takeEarning()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::Create(
   const bool _activarObjetivo,
   const double _objetivo,
   const ulong _deslizamiento,

   posicionPropia& _posicion[]
)
  {

   i_activarObjetivo = _activarObjetivo;

   if(!i_activarObjetivo)
      return true;

   i_objetivo = _objetivo;

   i_deslizamiento = _deslizamiento;

   if(ArrayResize(i_posicion, ArraySize(_posicion)) == -1)
     {
      Print("ArrayResize() == -1");
      return false;
     }

   for(int i = (ArraySize(_posicion) - 1); i >= 0; i--)
     {
      i_posicion[i].magico = _posicion[i].magico;
      i_posicion[i].simbolo = _posicion[i].simbolo;
     }

   m_cicloActivado = false;
   m_objetivoAlcanzado = false;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_takeEarning::inicializar()
  {

   if(!i_activarObjetivo)
      return;

   if(m_cicloActivado)
      return;

   m_balanceInicial = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("Ciclo abierto. Voy por " + DoubleToString(m_balanceInicial + i_objetivo, 2) + "\n");
   m_cicloActivado = true;
   m_objetivoAlcanzado = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::IntentarCerrar()
  {

   if(!i_activarObjetivo)
      return false;

   if(m_cicloActivado && !m_objetivoAlcanzado)
     {

      m_ganancia = AccountInfoDouble(ACCOUNT_EQUITY) - m_balanceInicial;

      if(m_ganancia < i_objetivo)
         return false;

      Print("\nCiclo cerrado. Alcance objetivo. Gané " + DoubleToString(m_ganancia, 2) + "\n");

      m_objetivoAlcanzado = true;

     }

   if(m_cicloActivado && m_objetivoAlcanzado)
     {

      string _mensaje;

      if(!CerrarTodasLasPosicionesCondicionada(
            i_posicion,
            _mensaje,
            i_deslizamiento
         ))
         return false;

      m_cicloActivado = false;

     }

   return true;

  }
//+------------------------------------------------------------------+

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

   bool              i_objetoActivado;
   double            i_gananciaEsperada;

   bool              m_cicloActivado;

   datetime          m_fechaApertura;
   datetime          m_fechaCierre;

   posicionPropia    m_posicion[];

public:
                     C_takeEarning();
                    ~C_takeEarning();

   bool              Create(
      const posicionPropia & _posicion[],
      const bool _objetoActivado,
      const double _objetivo
   );

   bool              Create(
      const string _simbolo,
      const ulong _magico,
      const bool _objetoActivado,
      const double _objetivo
   );

   bool              intentarInicializarCiclo();

   bool              evaluarObjetivo();

   bool              cerrarCiclo();

   bool              get_cicloActivado() { return m_cicloActivado; }

   bool              objetoActivado() { return i_objetoActivado; }

   bool              gananciaActual(double & _ganancia);

   double            gananciaEsperada() { return i_gananciaEsperada; }

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
bool C_takeEarning::cerrarCiclo()
  {

   if(ContarPendientes(m_posicion) > 0)
      return false;

   if(ContarPosiciones(m_posicion) > 0)
      return false;

   double _gananciaReal;

   if(!gananciaActual(_gananciaReal))
      return false;

   Print(
      "Take Earning finalizado." +
      "\nGanancia real: " + DoubleToString(_gananciaReal, 2) +
      "\nGanancia esperada: " + DoubleToString(gananciaEsperada(), 2) +
      "\n"
   );

   m_cicloActivado = false;
   m_fechaCierre = TimeCurrent();

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::Create(
   const string _simbolo,
   const ulong _magico,
   const bool _objetoActivado,
   const double _objetivo
)
  {

   posicionPropia _posicion[1];

   _posicion[0].magico = _magico;
   _posicion[0].simbolo = _simbolo;

   if(!Create(
         _posicion,
         _objetoActivado,
         _objetivo
      ))
      return false;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::Create(
   const posicionPropia & _posicion[],
   const bool _objetoActivado,
   const double _objetivo
)
  {

   i_objetoActivado = _objetoActivado;

   if(!i_objetoActivado)
      return true;

   if(ArrayResize(m_posicion, ArraySize(_posicion)) == -1)
      return false;

   for(int i= (ArraySize(_posicion) - 1); i >= 0; i--)
     {
      m_posicion[i].magico = _posicion[i].magico;
      m_posicion[i].simbolo = _posicion[i].simbolo;
     }

   i_gananciaEsperada = _objetivo;

   m_fechaCierre = 0;
   m_fechaApertura = 0;

   m_cicloActivado = false;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::intentarInicializarCiclo()
  {

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado");
      return true;
     }

   if(m_cicloActivado)
     {
      //Print("m_cicloActivado");
      return false;
     }

   if(!(TimeCurrent() > m_fechaCierre))
     {
      //Print("!(_fechaApertura > m_fechaCierre)");
      return false;
     }

   m_fechaApertura = TimeCurrent();

   Print("\nTakeEarning iniciado satisfactoriamente.\n");

   m_cicloActivado = true;


   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::evaluarObjetivo(void)
  {

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado");
      return true;
     }

   if(!m_cicloActivado)
     {
      //Print("!m_cicloActivado");
      return true;
     }

   double _ganancia;

   if(!gananciaActual(_ganancia))
     {
      //Print("!gananciaActual(_ganancia)");
      return false;
     }

   if(_ganancia < i_gananciaEsperada)
     {
      //Print("_ganancia < i_gananciaEsperada");
      return false;
     }

   Print(
      "\nLlegue a objetivo por take earning." +
      "\nGanancia actual: " + DoubleToString(_ganancia, 2)
   );

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::gananciaActual(double & _ganancia)
  {

   _ganancia = 0;

   if(!m_cicloActivado)
     {
      //Print("ciclo no activado");
      return false;
     }

   double _profitHistorico = 0;

   if(!ProfitHistorico(
         m_posicion,
         m_fechaApertura,
         TimeCurrent(),
         _profitHistorico
      ))
     {
      Print("!ProfitHistorico");
      return false;
     }

   _ganancia = profitFlotante(m_posicion) + _profitHistorico;

   return true;

  }

//+------------------------------------------------------------------+

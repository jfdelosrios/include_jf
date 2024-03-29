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

   bool              m_ObjetivoAlcanzado;

public:
                     C_takeEarning();
                    ~C_takeEarning();

   bool              Create(
      const bool _objetoActivado,
      const posicionPropia & _posicion[]
   );

   bool              Create(
      const bool _objetoActivado,
      const string _simbolo,
      const ulong _magico
   );

   bool              intentarInicializarCiclo(const double _gananciaEsperada);

   bool              refrescar();

   bool              IntentarCerrarCiclo();

   bool              get_cicloActivado() { return m_cicloActivado; }

   bool              objetoActivado() { return i_objetoActivado; }

   bool              get_gananciaFlotante(double & _ganancia);

   double            get_gananciaEsperada() { return i_gananciaEsperada; }

   bool              set_gananciaEsperada(const double _gananciaEsperada);

   bool              objetivoAlcanzado() { return m_ObjetivoAlcanzado; }

   datetime          fechaApertura() { return m_fechaApertura; }

   bool              puedePonerPosiciones();

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::puedePonerPosiciones()
  {

   if(!i_objetoActivado)
      return false;

   if(!m_cicloActivado)
      return false;

   if(!(TimeCurrent() > m_fechaApertura))
      return false;

   if(m_ObjetivoAlcanzado)
      return false;

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::set_gananciaEsperada(const double _gananciaEsperada)
  {

   if(!i_objetoActivado)
     {
      Print("!i_objetoActivado");
      return false;
     }

   if(m_ObjetivoAlcanzado)
     {
      Print("No puedo cambiar objetivo ya que ya lo alcance.");
      return false;
     }

   i_gananciaEsperada = _gananciaEsperada;

   Print(
      "\nVoy por " +
      DoubleToString(i_gananciaEsperada, 2) +
      " USD.\n"
   );

   return true;

  }


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
bool C_takeEarning::IntentarCerrarCiclo()
  {

   Print("\nIntentando finalizar Gestor Take Earning.");

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado");
      return true;
     }

   if(ContarPendientes(m_posicion, true) > 0)
     {
      Print("Gestor Take Earning aun no puede finalizar.");
      return false;
     }

   if(ContarPosiciones(m_posicion, true) > 0)
     {
      Print("Gestor Take Earning aun no puede finalizar.");
      return false;
     }

   datetime _fecha;

   if(!ultimoCierre(
         m_posicion,
         m_fechaApertura,
         TimeCurrent(),
         _fecha
      ))
     {
      Print("Gestor Take Earning aun no puede finalizar.");
      return false;
     }

   if(!(TimeCurrent() > _fecha))
     {

      Print(
         "Gestor Take Earning aun no puede finalizar, " +
         "fecha actual" + " <= " + "fecha del ultimo cierre" + "."
      );

      return false;
     }

   double _gananciaReal = 0;

   if(!get_BeneficioHistorico(
         m_posicion,
         m_fechaApertura,
         TimeCurrent(),
         _gananciaReal
      ))
     {
      Print("!get_ProfitHistorico(), " + __FUNCTION__);
      return false;
     }

   Print(
      "Gestor Take Earning finalizado." +
      "\nGanancia real: " + DoubleToString(_gananciaReal, 2) +
      "\nGanancia esperada: " + DoubleToString(get_gananciaEsperada(), 2) +
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
   const bool _objetoActivado,
   const string _simbolo,
   const ulong _magico
)
  {

   posicionPropia _posicion[1];

   _posicion[0].magico = _magico;
   _posicion[0].simbolo = _simbolo;

   if(!Create(_objetoActivado, _posicion))
      return false;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::Create(
   const bool _objetoActivado,
   const posicionPropia & _posicion[]
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

   i_gananciaEsperada = 0;

   m_fechaCierre = 0;
   m_fechaApertura = 0;

   m_cicloActivado = false;

   m_ObjetivoAlcanzado = false;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::intentarInicializarCiclo(const double _gananciaEsperada)
  {

   if(!i_objetoActivado)
     {
      Print("!i_objetoActivado");
      return true;
     }

   if(m_cicloActivado)
     {
      Print("m_cicloActivado");
      return false;
     }

   if(!(TimeCurrent() > m_fechaCierre))
     {

      Print(
         "\nGestor Take Earning requiere esperar un poco mas para abrir, " +
         "fechaApertura <= fechaCierre\n"
      );

      return false;
     }

   m_fechaApertura = TimeCurrent();

   Print("\nGestor Take Earning iniciado satisfactoriamente.\n");

   m_cicloActivado = true;

   m_ObjetivoAlcanzado = false;

   set_gananciaEsperada(_gananciaEsperada);

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::refrescar(void)
  {

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado, " + __FUNCTION__);
      return true;
     }

   if(!m_cicloActivado)
     {
      //Print("!m_cicloActivado");
      return true;
     }

   if(m_ObjetivoAlcanzado)
     {
      return true;
     }

   double _ganancia;

   if(!get_gananciaFlotante(_ganancia))
     {
      //Print("!get_gananciaFlotante(_ganancia)");
      return false;
     }

   if(_ganancia < i_gananciaEsperada)
     {
      //Print("_ganancia < i_gananciaEsperada");
      return true;
     }

   Print(
      "\nLlegue a objetivo por take earning." +
      "\nGanancia flotante: " + DoubleToString(_ganancia, 2) +
      "\nGanancia esperada: " + DoubleToString(get_gananciaEsperada(), 2)
   );

   m_ObjetivoAlcanzado = true;

   return true;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_takeEarning::get_gananciaFlotante(double & _ganancia)
  {

   _ganancia = 0;

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado, " + __FUNCTION__);
      return false;
     }

   if(!m_cicloActivado)
     {
      //Print("ciclo no activado");
      return false;
     }

   double _profitHistorico = 0;

   if(!get_BeneficioHistorico(
         m_posicion,
         m_fechaApertura,
         TimeCurrent(),
         _profitHistorico
      ))
     {
      Print("!get_ProfitHistorico(), " + __FUNCTION__);
      return false;
     }

   _ganancia = get_BeneficioFlotante(m_posicion) + _profitHistorico;

   return true;

  }

//+------------------------------------------------------------------+

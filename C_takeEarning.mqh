//+------------------------------------------------------------------+
//|                                                C_takeEarning.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "varios.mqh"
#include "C_CicloBase.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_takeEarning : public C_CicloBase
  {
private:

   double            i_gananciaEsperada;

public:
                     C_takeEarning();
                    ~C_takeEarning();

   bool              Create(
      const bool _objetoActivado,
      const string _simbolo,
      const ulong _magico
   );

   bool              intentarInicializarCiclo(const double _gananciaEsperada);

   bool              refrescar();

   bool              IntentarCerrarCiclo();

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

   if(!i_objetoActivado)
     {
      //Print("!i_objetoActivado");
      return true;
     }

   if(!m_cicloActivado)
     {
      return true;
     }

   if(ContarPendientes(m_simbolo.Name(), i_magico, false) > 0)
     {

      Print(
         "\nGestor Take Earning aun no puede finalizar. " +
         "Hay ordenes pendientes puestas.\n"
      );

      return false;
     }

   if(ContarPosiciones(m_simbolo.Name(), i_magico, false) > 0)
     {

      Print(
         "\nGestor Take Earning aun no puede finalizar. " +
         "Hay posiciones abiertas.\n"
      );

      return false;
     }

   datetime _fecha;

   if(!ultimoCierre(
         m_simbolo.Name(),
         i_magico,
         m_fechaApertura,
         TimeCurrent(),
         _fecha
      ))
     {

      Print(
         "\nGestor Take Earning aun no puede finalizar. !ultimoCierre, " +
         __FUNCTION__ + ".\n"
      );

      return false;
     }

   if(!(TimeCurrent() > _fecha))
     {

      Print(
         "\nGestor Take Earning aun no puede finalizar, " +
         "fecha actual" + " <= " + "fecha del ultimo cierre" + ".\n"
      );

      return false;
     }

   double _gananciaReal = 0;

   if(!get_BeneficioHistorico(
         m_simbolo.Name(),
         i_magico,
         m_fechaApertura,
         TimeCurrent(),
         _gananciaReal
      ))
     {
      Print("\n!get_ProfitHistorico(), " + __FUNCTION__ + ".\n");
      return false;
     }

   Print(
      "\nGestor Take Earning finalizado." +
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

   i_objetoActivado = _objetoActivado;

   if(!i_objetoActivado)
      return true;

   if(!m_simbolo.Name(_simbolo))
     {
      Print("!m_simbolo.Name(_simbolo), " + __FUNCTION__);
      return false;
     }

   i_magico = _magico;

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
         "\nGestor Take Earning aun no puede iniciar, " +
         "fechaApertura <= fechaCierre\n"
      );

      return false;
     }

   m_fechaApertura = TimeCurrent();

   Print(
      "\nGestor Take Earning iniciado satisfactoriamente. " +
      TimeToString(m_fechaApertura, TIME_DATE|TIME_SECONDS) +
      "\n"
   );

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
      "\nGanancia flotante actual: " + DoubleToString(_ganancia, 2) +
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
         m_simbolo.Name(),
         i_magico,
         m_fechaApertura,
         TimeCurrent(),
         _profitHistorico
      ))
     {
      Print("!get_ProfitHistorico(), " + __FUNCTION__);
      return false;
     }

   _ganancia = get_BeneficioFlotante(m_simbolo.Name(), i_magico) + _profitHistorico;

   return true;

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                          C_FiltroRangoTiempo.mqh |
//|                      Copyright 2022, Brickell Financial Advisors |
//|                            https://brickellfinancialadvisors.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Brickell Financial Advisors"
#property link      "https://brickellfinancialadvisors.com"
#property version   "1.00"
#property strict

#include <Tools/DateTime.mqh>


struct struct_franjaHoraria
  {
   MqlDateTime               inicio;
   MqlDateTime               fin;
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_FiltroRangoTiempo
  {
private:

   struct_franjaHoraria m_franjaHoraria;

   bool              resetear_datetime(const datetime _fecha);

public:

                     C_FiltroRangoTiempo();
                    ~C_FiltroRangoTiempo();

   bool              EstaEntreRango(const datetime _fecha, bool &_salida);

   void              set_Time_inicio(
      const uchar _hora,
      const uchar _minuto,
      uchar _segundo
   );

   void              set_Time_fin(
      const uchar _hora,
      const uchar _minuto,
      uchar _segundo
   );

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_FiltroRangoTiempo::C_FiltroRangoTiempo()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_FiltroRangoTiempo::~C_FiltroRangoTiempo()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_FiltroRangoTiempo::resetear_datetime(const datetime _fecha)
  {
   MqlDateTime dt_struct ;

   if(!TimeToStruct(_fecha, dt_struct))
     {
      return false;
     }

   m_franjaHoraria.inicio.year = dt_struct.year;
   m_franjaHoraria.inicio.mon = dt_struct.mon;
   m_franjaHoraria.inicio.day = dt_struct.day;

   m_franjaHoraria.fin.year = dt_struct.year;
   m_franjaHoraria.fin.mon = dt_struct.mon;
   m_franjaHoraria.fin.day = dt_struct.day;

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_FiltroRangoTiempo::set_Time_inicio(
   const uchar _hora,
   const uchar _minuto,
   uchar _segundo = 0
)
  {
   m_franjaHoraria.inicio.hour = _hora;
   m_franjaHoraria.inicio.min = _minuto;
   m_franjaHoraria.inicio.sec = _segundo;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_FiltroRangoTiempo::set_Time_fin(
   const uchar _hora,
   const uchar _minuto,
   uchar _segundo = 0
)
  {
   m_franjaHoraria.fin.hour = _hora;
   m_franjaHoraria.fin.min = _minuto;
   m_franjaHoraria.fin.sec = _segundo;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_FiltroRangoTiempo::EstaEntreRango(const datetime _fecha, bool &_salida)
  {

   _salida =false;

   if(!resetear_datetime(_fecha))
      return false;

   const datetime _fechaInicio = StructToTime(m_franjaHoraria.inicio);
   const datetime _fechaFin = StructToTime(m_franjaHoraria.fin);

   if(_fechaInicio < _fechaFin)
     {

      if(!((_fecha >= _fechaInicio) && (_fecha < _fechaFin)))
         return true;

      _salida = true;

     }

   if(_fechaInicio > _fechaFin)
     {

      if(!((_fecha >= _fechaInicio) || (_fecha < _fechaFin)))
         return true;

      _salida = true;

     }


   return true;

  }
//+------------------------------------------------------------------+

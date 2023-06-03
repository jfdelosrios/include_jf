//+------------------------------------------------------------------+
//|                                                  C_CicloBase.mqh |
//|                             Copyright 2022, BrickellFintech Ltd. |
//|                                      https://brickellfintech.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, BrickellFintech Ltd."
#property link      "https://brickellfintech.com"
#property version   "1.00"

#include <Trade\SymbolInfo.mqh>


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_CicloBase
  {
protected:

   bool              i_objetoActivado;

   CSymbolInfo       m_simbolo;

   ulong             i_magico;

   bool              m_cicloActivado;

   datetime          m_fechaApertura;

   datetime          m_fechaCierre;

   bool              m_ObjetivoAlcanzado;


public:
                     C_CicloBase();
                    ~C_CicloBase();
   
   bool              get_cicloActivado() { return m_cicloActivado; }

   bool              objetoActivado() { return i_objetoActivado; }

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_CicloBase::C_CicloBase()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_CicloBase::~C_CicloBase()
  {
  }

//+------------------------------------------------------------------+

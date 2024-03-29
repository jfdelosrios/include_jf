//+------------------------------------------------------------------+
//|                                                   C_telegram.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_telegram
  {
private:
   string            i_token;
   string            i_canal;

   bool              i_objetoActivado;

public:
                     C_telegram();
                    ~C_telegram();

   void              inicializar(
      const string _token,
      const string _canal,
      const bool _objetoActivado
   );

   bool              enviarMensaje(string _mensaje);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_telegram::C_telegram()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_telegram::~C_telegram()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void C_telegram::inicializar(
   const string _token,
   const string _canal,
   const bool _objetoActivado)
  {
   i_token = _token;
   i_canal = _canal;
   i_objetoActivado = _objetoActivado;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool C_telegram::enviarMensaje(string _mensaje)
  {

   if(!i_objetoActivado)
      return true;

   string cookie = NULL;
   string headers;
   char   result[];
   char   post[];

   const string url = "https://api.telegram.org/";

   Print("");

   if(StringReplace(_mensaje," ", "%20") == -1)
     {
      Print("(StringReplace(url1,' ', '%20') == -1)" + __FUNCTION__ + "\n");
      return false;
     }

   if(StringReplace(_mensaje,"\n", "%0A") == -1)
     {
      Print("(StringReplace(url1,'\n', '%0A') == -1)" + __FUNCTION__ + "\n");
      return false;
     }

   string url1 =
      url +
      "bot" + i_token +
      "/sendMessage?" +
      "chat_id=" + i_canal +
      "&text=" + _mensaje
      ;

   Print("Enviando \n" + url1);

   if(MQLInfoInteger(MQL_TESTER))
     {
      Print("");
      return true;
     }

   const int res = WebRequest(
                      "GET",
                      url1,
                      cookie,
                      NULL,
                      500,
                      post,
                      0,
                      result,
                      headers
                   );

   if(_LastError == ERR_WEBREQUEST_REQUEST_FAILED)
     {

      Print(
         "ERR_WEBREQUEST_REQUEST_FAILED, " +
         __FUNCTION__ +
         "\n" +
         "Puede ser que haya fallado la conexión a internet " +
         "o el mensaje este corrupto."
         "\n"
      );

      ResetLastError();
      return false;

     }

   if(_LastError == ERR_FUNCTION_NOT_ALLOWED)
     {

      Print(
         "ERR_FUNCTION_NOT_ALLOWED, " +
         __FUNCTION__ +
         "\n" +
         "Puede ser que la URL " + url + "no se encuentre inscrita en la plataforma."
         "\n"
      );

      //ResetLastError();
      return false;

     }

   if(_LastError != 0)
     {
      Print("Error " + IntegerToString(_LastError) + " " + __FUNCTION__ + "\n");
      //ResetLastError();
      return false;
     }

   Print(CharArrayToString(result) + "\n");

   if(res != 200)
      return false;

   return true;

  }
//+------------------------------------------------------------------+

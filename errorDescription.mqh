//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int err_code)
  {
   switch(err_code)
     {

#ifdef __MQL5__
      case ERR_SUCCESS: return("La operación se ha ejecutado con éxito");
      case ERR_INTERNAL_ERROR: return("Error interno inesperado");
      case ERR_WRONG_INTERNAL_PARAMETER: return("Parámetro erróneo durante la llamada built-in a la función del terminal de cliente");
      case ERR_INVALID_PARAMETER: return("Parámetro erróneo durante la llamada a la función de sistema");
      case ERR_NOT_ENOUGH_MEMORY: return("No hay memoria suficiente para ejecutar la función de sistema");
      case ERR_STRUCT_WITHOBJECTS_ORCLASS: return("Estructura contiene objetos de cadenas y/o de arrays dinámicos y/o estructuras con estos objetos y/o clases");
      case ERR_INVALID_ARRAY: return("Array del tipo inapropiado, tamaño inapropiado o objeto dañado del array dinámico");
      case ERR_ARRAY_RESIZE_ERROR: return("No hay memoria suficiente para la reubicación de un array, o un intento de cambio del tamaño de un array estático");
      case ERR_STRING_RESIZE_ERROR: return("No hay memoria suficiente para la reubicación de una cadena");
      case ERR_NOTINITIALIZED_STRING: return("Cadena no inicializada");
      case ERR_INVALID_DATETIME: return("Valor de fecha y/o hora incorrecto");
      case ERR_ARRAY_BAD_SIZE: return("Tamaño solicitado del array supera 2 gigabytes");
      case ERR_INVALID_POINTER: return("Puntero erróneo");
      case ERR_INVALID_POINTER_TYPE: return("Tipo erróneo del puntero");
      case ERR_FUNCTION_NOT_ALLOWED: return("Función de sistema no está permitida para la llamada");
      case ERR_RESOURCE_NAME_DUPLICATED: return("Coincidencia del nombre del recurso dinámico y estático");
      case ERR_RESOURCE_NOT_FOUND: return("Recurso con este nombre no encontrado en EX5");
      case ERR_RESOURCE_UNSUPPOTED_TYPE: return("Tipo del recurso no soportado o el tamaño superior a 16 Mb");
      case ERR_RESOURCE_NAME_IS_TOO_LONG: return("Nombre del recurso supera 63 caracteres");
      case ERR_MATH_OVERFLOW: return("Desbordamiento (overflow) ocurrido al calcular la función");
      //	Gráficos			
      case ERR_CHART_WRONG_ID: return("Identificador erróneo del gráfico");
      case ERR_CHART_NO_REPLY: return("Gráfico no responde");
      case ERR_CHART_NOT_FOUND: return("Gráfico no encontrado");
      case ERR_CHART_NO_EXPERT: return("Gráfico no tiene un Asesor Experto que pueda procesar el evento");
      case ERR_CHART_CANNOT_OPEN: return("Error al abrir el gráfico");
      case ERR_CHART_CANNOT_CHANGE: return("Error al cambiar el símbolo y período del gráfico");
      case ERR_CHART_WRONG_PARAMETER: return("Valor erróneo del parámetro para la función de trabajo con los gráficos");
      case ERR_CHART_CANNOT_CREATE_TIMER: return("Error al crear el temporizador");
      case ERR_CHART_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del gráfico");
      case ERR_CHART_SCREENSHOT_FAILED: return("Error al crear un screenshot");
      case ERR_CHART_NAVIGATE_FAILED: return("error de navegación por el gráfico");
      case ERR_CHART_TEMPLATE_FAILED: return("Error al aplicar una plantilla");
      case ERR_CHART_WINDOW_NOT_FOUND: return("Subventana que contiene el indicador especificado no encontrada");
      case ERR_CHART_INDICATOR_CANNOT_ADD: return("Error al insertar un indicador en el gráfico");
      case ERR_CHART_INDICATOR_CANNOT_DEL: return("Error al quitar un indicador desde el gráfico");
      case ERR_CHART_INDICATOR_NOT_FOUND: return("El indicador no ha sido encontrado en el gráfico especificado");
      //	Objetos gráficos			
      case ERR_OBJECT_ERROR: return("Error al manejar un objeto gráfico");
      case ERR_OBJECT_NOT_FOUND: return("Objeto gráfico no encontrado");
      case ERR_OBJECT_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del objeto gráfico");
      case ERR_OBJECT_GETDATE_FAILED: return("Imposible recibir fecha correspondiente al valor");
      case ERR_OBJECT_GETVALUE_FAILED: return("Imposible recibir valor correspondiente a la fecha");
      //	MarketInfo			
      case ERR_MARKET_UNKNOWN_SYMBOL: return("Símbolo desconocido");
      case ERR_MARKET_NOT_SELECTED: return("Símbolo no está seleccionado en MarketWatch");
      case ERR_MARKET_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del símbolo");
      case ERR_MARKET_LASTTIME_UNKNOWN: return("Hora del último tick no se conoce (no había ticks)");
      case ERR_MARKET_SELECT_ERROR: return("Error al agregar o eliminar el símbolo a/de MarketWatch");
      //	Acceso al historial			
      case ERR_HISTORY_NOT_FOUND: return("Historial solicitado no encontrado");
      case ERR_HISTORY_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del historial");
      case ERR_HISTORY_TIMEOUT: return("Se ha superado el límite de tiempo al solicitar la historia");
      case ERR_HISTORY_BARS_LIMIT: return("El número de barras solicitado está limitado por los ajustes del terminal");
      case ERR_HISTORY_LOAD_ERRORS: return("Errores múltiples al cargar la historia");
      case ERR_HISTORY_SMALL_BUFFER: return("La matriz receptora es demasiado pequeña para almacenar los datos solicitados");
      //	Global_Variables			
      case ERR_GLOBALVARIABLE_NOT_FOUND: return("Variable global del terminal de cliente no encontrada");
      case ERR_GLOBALVARIABLE_EXISTS: return("Variable global del terminal de cliente con este nombre ya existe");
      case ERR_GLOBALVARIABLE_NOT_MODIFIED: return("Las variables globales no han sido modificadas");
      case ERR_GLOBALVARIABLE_CANNOTREAD: return("No ha sido posible abrir y leer el archivo con los valores de las variables globales");
      case ERR_GLOBALVARIABLE_CANNOTWRITE: return("No ha sido posible grabar el archivo con los valores de las variables globales");
      case ERR_MAIL_SEND_FAILED: return("Envío de carta fallido");
      case ERR_PLAY_SOUND_FAILED : return("Reproducción de sonido fallido");
      case ERR_MQL5_WRONG_PROPERTY : return("Identificador erróneo de la propiedad del programa");
      case ERR_TERMINAL_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del terminal");
      case ERR_FTP_SEND_FAILED : return("Envío de archivo a través de ftp fallido");
      case ERR_NOTIFICATION_SEND_FAILED: return("No se ha podido enviar la notificación");
      case ERR_NOTIFICATION_WRONG_PARAMETER: return("Parámetro incorrecto para el envío de la notificación – en la función SendNotification() han pasado una línea vacía o NULL");
      case ERR_NOTIFICATION_WRONG_SETTINGS: return("Ajustes incorrectos de las notificaciones en el terminal (ID no especificada o permiso no concedido)");
      case ERR_NOTIFICATION_TOO_FREQUENT: return("Envío de notificaciones muy frecuente");
      case ERR_FTP_NOSERVER: return("No se ha indicado el servidor ftp en los ajustes");
      case ERR_FTP_NOLOGIN: return("No se ha indicado el login ftp en los ajustes");
      case ERR_FTP_FILE_ERROR: return("El archivo no existe");
      case ERR_FTP_CONNECT_FAILED: return("No ha sido posible conectarse al servidor ftp");
      case ERR_FTP_CHANGEDIR: return("En el servidor ftp no se ha encontrado el directorio para cargar el archivo");
      case ERR_FTP_CLOSED : return("La conexión al servidor ftp está cerrada");
      //	Buffers de indicadores personalizados			
      case ERR_BUFFERS_NO_MEMORY: return("No hay memoria suficiente para la redistribución de buffers de indicadores");
      case ERR_BUFFERS_WRONG_INDEX: return("Índice erróneo de su búfer de indicadores");
      //	Propiedades de indicadores personalizados			
      case ERR_CUSTOM_WRONG_PROPERTY: return("Identificador erróneo de la propiedad del indicador personalizado");
      //	Account			
      case ERR_ACCOUNT_WRONG_PROPERTY: return("Identificador erróneo de la propiedad de la cuenta");
      case ERR_TRADE_WRONG_PROPERTY: return("Identificador erróneo de la propiedad de la actividad comercial");
      case ERR_TRADE_DISABLED: return("Prohibida la actividad comercial para el Asesor Experto");
      case ERR_TRADE_POSITION_NOT_FOUND: return("Posición no encontrada");
      case ERR_TRADE_ORDER_NOT_FOUND: return("Orden no encontrada");
      case ERR_TRADE_DEAL_NOT_FOUND: return("Transacción no encontrada");
      case ERR_TRADE_SEND_FAILED: return("Envío de solicitud comercial fallida");
      case ERR_TRADE_CALC_FAILED: return("Fallo al calcular el valor del beneficio o el margen");
      //	Indicadores			
      case ERR_INDICATOR_UNKNOWN_SYMBOL: return("Símbolo desconocido");
      case ERR_INDICATOR_CANNOT_CREATE: return("No se puede crear indicador");
      case ERR_INDICATOR_NO_MEMORY: return("Memoria insuficiente para añadir el indicador");
      case ERR_INDICATOR_CANNOT_APPLY: return("Indicador no puede ser aplicado a otro indicador");
      case ERR_INDICATOR_CANNOT_ADD: return("Error al añadir indicador");
      case ERR_INDICATOR_DATA_NOT_FOUND: return("Datos solicitados no encontrados");
      case ERR_INDICATOR_WRONG_HANDLE: return("Handle del indicador es erróneo");
      case ERR_INDICATOR_WRONG_PARAMETERS: return("Número erróneo de parámetros al crear un indicador");
      case ERR_INDICATOR_PARAMETERS_MISSING: return("No hay parámetros cuando se crea un indicador");
      case ERR_INDICATOR_CUSTOM_NAME: return("El primer parámetro en la matriz tiene que ser el nombre del indicador personalizado");
      case ERR_INDICATOR_PARAMETER_TYPE: return("Tipo erróneo del parámetro en la matriz al crear un indicador");
      case ERR_INDICATOR_WRONG_INDEX: return("Índice del búfer de indicador que se solicita es erróneo");
      //	Profundidad de Mercado			
      case ERR_BOOKS_CANNOT_ADD: return("No se puede añadir la profundidad de mercado");
      case ERR_BOOKS_CANNOT_DELETE: return("No se puede eliminar la profundidad de mercado");
      case ERR_BOOKS_CANNOT_GET: return("No se puede obtener los datos de la profundidad de mercado");
      case ERR_BOOKS_CANNOT_SUBSCRIBE: return("Error al suscribirse a la recepción de nuevos datos de la profundidad de mercado");
      //	Operaciones con archivos			
      case ERR_TOO_MANY_FILES: return("No se puede abrir más de 64 archivos");
      case ERR_WRONG_FILENAME: return("Nombre del archivo no válido");
      case ERR_TOO_LONG_FILENAME: return("Nombre del archivo demasiado largo");
      case ERR_CANNOT_OPEN_FILE: return("Error al abrir el archivo");
      case ERR_FILE_CACHEBUFFER_ERROR: return("Memoria insuficiente para la caché de lectura");
      case ERR_CANNOT_DELETE_FILE: return("Error al eliminar el archivo");
      case ERR_INVALID_FILEHANDLE: return("Archivo con este manejador ya está cerrado, o no se abría en absoluto");
      case ERR_WRONG_FILEHANDLE: return("Manejador erróneo de archivo");
      case ERR_FILE_NOTTOWRITE: return("El archivo debe ser abierto para la escritura");
      case ERR_FILE_NOTTOREAD: return("El archivo debe ser abierto para la lectura");
      case ERR_FILE_NOTBIN: return("El archivo debe ser abierto como un archivo binario");
      case ERR_FILE_NOTTXT: return("El archivo debe ser abierto como un archivo de texto");
      case ERR_FILE_NOTTXTORCSV: return("El archivo debe ser abierto como un archivo de texto o CSV");
      case ERR_FILE_NOTCSV: return("El archivo debe ser abierto como un archivo CSV");
      case ERR_FILE_READERROR: return("Error de lectura de archivo");
      case ERR_FILE_BINSTRINGSIZE: return("Hay que especificar el tamaño de la cadena porque el archivo ha sido abierto como binario");
      case ERR_INCOMPATIBLE_FILE: return("Para los arrays de cadenas - un archivo de texto, para los demás - un archivo binario");
      case ERR_FILE_IS_DIRECTORY: return("No es un archivo, es un directorio");
      case ERR_FILE_NOT_EXIST: return("Archivo no existe");
      case ERR_FILE_CANNOT_REWRITE: return("No se puede reescribir el archivo");
      case ERR_WRONG_DIRECTORYNAME: return("Nombre erróneo del directorio");
      case ERR_DIRECTORY_NOT_EXIST: return("Directorio no existe");
      case ERR_FILE_ISNOT_DIRECTORY: return("Es un archivo, no es un directorio");
      case ERR_CANNOT_DELETE_DIRECTORY: return("No se puede eliminar el directorio");
      case ERR_CANNOT_CLEAN_DIRECTORY: return("No se puede limpiar el directorio (tal vez, uno o más archivos estén bloqueados y no se ha podido llevar a cabo la eliminación)");
      case ERR_MQL_FILE_WRITEERROR: return("No se ha podido escribir el recurso en el archivo");
      case ERR_FILE_ENDOFFILE: return("No se ha podido leer el siguiente fragmento de datos del archivo CSV (FileReadString, FileReadNumber, FileReadDatetime, FileReadBool), puesto que se ha alcanzado el final del archivo");
      //	Conversión de cadenas			
      case ERR_NO_STRING_DATE: return("No hay fecha en la cadena");
      case ERR_WRONG_STRING_DATE: return("Fecha errónea en la cadena");
      case ERR_WRONG_STRING_TIME: return("Hora errónea en la cadena");
      case ERR_STRING_TIME_ERROR: return("Error de conversión de cadena a fecha");
      case ERR_STRING_OUT_OF_MEMORY: return("Memoria insuficiente para la cadena");
      case ERR_STRING_SMALL_LEN: return("Longitud de cadena es menos de la esperada");
      case ERR_STRING_TOO_BIGNUMBER: return("Número excesivamente grande, más que ULONG_MAX");
      case ERR_WRONG_FORMATSTRING: return("Cadena de formato errónea");
      case ERR_TOO_MANY_FORMATTERS: return("Hay más especificadores de formato que los parámetros");
      case ERR_TOO_MANY_PARAMETERS: return("Hay más Parámetros que los especificadores de formato");
      case ERR_WRONG_STRING_PARAMETER: return("Parámetro del tipo string dañado");
      case ERR_STRINGPOS_OUTOFRANGE: return("Posición fuera de los límites de la cadena");
      case ERR_STRING_ZEROADDED: return("Al final de la cadena se ha añadido 0, una operación inútil");
      case ERR_STRING_UNKNOWNTYPE: return("Tipo de datos desconocido durante la conversión a una cadena");
      case ERR_WRONG_STRING_OBJECT: return("Objeto de cadena dañado");
      //	Operaciones con matrices			
      case ERR_INCOMPATIBLE_ARRAYS: return("Copiado de los arrays incompatibles. Un array de cadena puede ser copiado sólo en un array de cadena, un array numérico sólo en un array numérico");
      case ERR_SMALL_ASSERIES_ARRAY: return("El array que recibe está declarado como AS_SERIES, y no tiene el tamaño suficiente");
      case ERR_SMALL_ARRAY: return("Un array muy pequeño, posición de inicio está fuera de los límites del array");
      case ERR_ZEROSIZE_ARRAY: return("Un array de longitud cero");
      case ERR_NUMBER_ARRAYS_ONLY: return("Tiene que ser un array numérico");
      case ERR_ONEDIM_ARRAYS_ONLY: return("Tiene que ser un array unidimensional");
      case ERR_SERIES_ARRAY: return("No se puede usar serie temporal");
      case ERR_DOUBLE_ARRAY_ONLY: return("Tiene que ser un array del tipo double");
      case ERR_FLOAT_ARRAY_ONLY: return("Tiene que ser un array del tipo float");
      case ERR_LONG_ARRAY_ONLY: return("Tiene que ser un array del tipo long");
      case ERR_INT_ARRAY_ONLY: return("Tiene que ser un array del tipo int");
      case ERR_SHORT_ARRAY_ONLY: return("Tiene que ser un array del tipo short");
      case ERR_CHAR_ARRAY_ONLY: return("Tiene que ser un array del tipo char");
      case ERR_STRING_ARRAY_ONLY: return("Solo matrices del tipo string");
      //	Trabajo con OpenCL			
      case ERR_OPENCL_NOT_SUPPORTED: return("Las funciones OpenCL no se soportan en este ordenador");
      case ERR_OPENCL_INTERNAL: return("Error interno al ejecutar OpenCL");
      case ERR_OPENCL_INVALID_HANDLE: return("Manejado OpenCL incorrecto");
      case ERR_OPENCL_CONTEXT_CREATE: return("Error al crear el contexto OpenCL");
      case ERR_OPENCL_QUEUE_CREATE: return("Error al crear la cola de ejecución en OpenCL");
      case ERR_OPENCL_PROGRAM_CREATE : return("Error al compilar el programa OpenCL");
      case ERR_OPENCL_TOO_LONG_KERNEL_NAME: return("Punto de entrada demasiado largo (kernel OpenCL)");
      case ERR_OPENCL_KERNEL_CREATE : return("Error al crear el kernel - punto de entrada de OpenCL");
      case ERR_OPENCL_SET_KERNEL_PARAMETER: return("Error al establecer los parámetros para el kernel OpenCL (punto de entrada en el programa OpenCL)");
      case ERR_OPENCL_EXECUTE: return("Error de ejecución del programa OpenCL");
      case ERR_OPENCL_WRONG_BUFFER_SIZE: return("Tamaño del búfer OpenCL incorrecto");
      case ERR_OPENCL_WRONG_BUFFER_OFFSET: return("Desplazamiento incorrecto en el búfer OpenCL");
      case ERR_OPENCL_BUFFER_CREATE: return("Error de creación del búfer OpenCL");
      case ERR_OPENCL_TOO_MANY_OBJECTS: return("Se ha superado el número de objetos OpenCL");
      case ERR_OPENCL_SELECTDEVICE: return("Error al elegir el dispositivo OpenCL");
      //	Trabajo con WebRequest			
      case ERR_WEBREQUEST_INVALID_ADDRESS: return("URL no ha superado la prueba");
      case ERR_WEBREQUEST_CONNECT_FAILED: return("No se ha podido conectarse a la URL especificada");
      case ERR_WEBREQUEST_TIMEOUT: return("Superado el tiempo de espera de recepción de datos");
      case ERR_WEBREQUEST_REQUEST_FAILED: return("Error de ejecución de la solicitud HTTP");
      //	Símbolos personalizados			
      case ERR_NOT_CUSTOM_SYMBOL: return("Debe indicarse un símbolo personalizado");
      case ERR_CUSTOM_SYMBOL_WRONG_NAME: return(""Nombre del símbolo personalizado incorrecto. En el nombre dado al símbolo se usan solo letras latinas sin signos de puntuación, sin espacios en blanco y ni símbolos especiales (se permiten ""."", ""_"", ""&"" y ""#""). No se recomienda utilizar los símbolos <, >, :, "", /,\, |, ?, *."");
      case ERR_CUSTOM_SYMBOL_NAME_LONG: return("Nombre demasiado largo para el símbolo personalizado. La longitud del nombre no deberá superar los 32 caracteres contando el 0 final");
      case ERR_CUSTOM_SYMBOL_PATH_LONG: return(""Ruta para el símbolo personalizado demasiado larga. La longitud de la ruta no deberá superar los 128 caracteres incluyendo ""Custom\\"", el nombre del símbolo, los separadores de grupos y el 0 final"");
      case ERR_CUSTOM_SYMBOL_EXIST: return("No existe ningún símbolo personalizado con ese nombre");
      case ERR_CUSTOM_SYMBOL_ERROR: return("Error al crear, eliminar o modificar el símbolo personalizado");
      case ERR_CUSTOM_SYMBOL_SELECTED: return("Intento de eliminar un símbolo personalizado elegido en la observación de mercado (Market Watch)");
      case ERR_CUSTOM_SYMBOL_PROPERTY_WRONG: return("Propiedad de símbolo personalizado incorrecta");
      case ERR_CUSTOM_SYMBOL_PARAMETER_ERROR: return("Parámetro erróneo al establecer las propiedades del símbolo personalizado");
      case ERR_CUSTOM_SYMBOL_PARAMETER_LONG: return("Parámetro de cadena demasiado largo al establecer las propiedades del símbolo personalizado");
      case ERR_CUSTOM_TICKS_WRONG_ORDER: return("Matriz de ticks no organizada por tiempo");
      //	Errores de usuario 			
      case ERR_USER_ERROR_FIRST: return("A partir de este código se empiezan los errores definidos por el usuario");
#endif
#ifdef __MQL4__
      case ERR_NO_ERROR: return("No error returned");
      case ERR_NO_RESULT: return("No error returned, but the result is unknown");
      case ERR_COMMON_ERROR: return("Common error");
      case ERR_INVALID_TRADE_PARAMETERS: return("Invalid trade parameters");
      case ERR_SERVER_BUSY: return("Trade server is busy");
      case ERR_OLD_VERSION: return("Old version of the client terminal");
      case ERR_NO_CONNECTION: return("No connection with trade server");
      case ERR_NOT_ENOUGH_RIGHTS: return("Not enough rights");
      case ERR_TOO_FREQUENT_REQUESTS: return("Too frequent requests");
      case ERR_MALFUNCTIONAL_TRADE: return("Malfunctional trade operation");
      case ERR_ACCOUNT_DISABLED: return("Account disabled");
      case ERR_INVALID_ACCOUNT: return("Invalid account");
      case ERR_TRADE_TIMEOUT: return("Trade timeout");
      case ERR_INVALID_PRICE: return("Invalid price");
      case ERR_INVALID_STOPS: return("Invalid stops");
      case ERR_INVALID_TRADE_VOLUME: return("Invalid trade volume");
      case ERR_MARKET_CLOSED: return("Market is closed");
      case ERR_TRADE_DISABLED: return("Trade is disabled");
      case ERR_NOT_ENOUGH_MONEY: return("Not enough money");
      case ERR_PRICE_CHANGED: return("Price changed");
      case ERR_OFF_QUOTES: return("Off quotes");
      case ERR_BROKER_BUSY: return("Broker is busy");
      case ERR_REQUOTE: return("Requote");
      case ERR_ORDER_LOCKED: return("Order is locked");
      case ERR_LONG_POSITIONS_ONLY_ALLOWED: return("Buy orders only allowed");
      case ERR_TOO_MANY_REQUESTS: return("Too many requests");
      case ERR_TRADE_MODIFY_DENIED: return("Modification denied because order is too close to market");
      case ERR_TRADE_CONTEXT_BUSY: return("Trade context is busy");
      case ERR_TRADE_EXPIRATION_DENIED: return("Expirations are denied by broker");
      case ERR_TRADE_TOO_MANY_ORDERS: return("The amount of open and pending orders has reached the limit set by the broker");
      case ERR_TRADE_HEDGE_PROHIBITED: return("An attempt to open an order opposite to the existing one when hedging is disabled");
      case ERR_TRADE_PROHIBITED_BY_FIFO: return("An attempt to close an order contravening the FIFO rule");
      case ERR_NO_MQLERROR: return("No error returned");
      case ERR_WRONG_FUNCTION_POINTER: return("Wrong function pointer");
      case ERR_ARRAY_INDEX_OUT_OF_RANGE: return("Array index is out of range");
      case ERR_NO_MEMORY_FOR_CALL_STACK: return("No memory for function call stack");
      case ERR_RECURSIVE_STACK_OVERFLOW: return("Recursive stack overflow");
      case ERR_NOT_ENOUGH_STACK_FOR_PARAM: return("Not enough stack for parameter");
      case ERR_NO_MEMORY_FOR_PARAM_STRING: return("No memory for parameter string");
      case ERR_NO_MEMORY_FOR_TEMP_STRING: return("No memory for temp string");
      case ERR_NOT_INITIALIZED_STRING: return("Not initialized string");
      case ERR_NOT_INITIALIZED_ARRAYSTRING: return("Not initialized string in array");
      case ERR_NO_MEMORY_FOR_ARRAYSTRING: return("No memory for array string");
      case ERR_TOO_LONG_STRING: return("Too long string");
      case ERR_REMAINDER_FROM_ZERO_DIVIDE: return("Remainder from zero divide");
      case ERR_ZERO_DIVIDE: return("Zero divide");
      case ERR_UNKNOWN_COMMAND: return("Unknown command");
      case ERR_WRONG_JUMP: return("Wrong jump (never generated error)");
      case ERR_NOT_INITIALIZED_ARRAY: return("Not initialized array");
      case ERR_DLL_CALLS_NOT_ALLOWED: return("DLL calls are not allowed");
      case ERR_CANNOT_LOAD_LIBRARY: return("Cannot load library");
      case ERR_CANNOT_CALL_FUNCTION: return("Cannot call function");
      case ERR_EXTERNAL_CALLS_NOT_ALLOWED: return("Expert function calls are not allowed");
      case ERR_NO_MEMORY_FOR_RETURNED_STR: return("Not enough memory for temp string returned from function");
      case ERR_SYSTEM_BUSY: return("System is busy (never generated error)");
      case ERR_DLLFUNC_CRITICALERROR: return("DLL-function call critical error");
      case ERR_INTERNAL_ERROR: return("Internal error");
      case ERR_OUT_OF_MEMORY: return("Out of memory");
      case ERR_INVALID_POINTER: return("Invalid pointer");
      case ERR_FORMAT_TOO_MANY_FORMATTERS: return("Too many formatters in the format function");
      case ERR_FORMAT_TOO_MANY_PARAMETERS: return("Parameters count exceeds formatters count");
      case ERR_ARRAY_INVALID: return("Invalid array");
      case ERR_CHART_NOREPLY: return("No reply from chart");
      case ERR_INVALID_FUNCTION_PARAMSCNT: return("Invalid function parameters count");
      case ERR_INVALID_FUNCTION_PARAMVALUE: return("Invalid function parameter value");
      case ERR_STRING_FUNCTION_INTERNAL: return("String function internal error");
      case ERR_SOME_ARRAY_ERROR: return("Some array error");
      case ERR_INCORRECT_SERIESARRAY_USING: return("Incorrect series array using");
      case ERR_CUSTOM_INDICATOR_ERROR: return("Custom indicator error");
      case ERR_INCOMPATIBLE_ARRAYS: return("Arrays are incompatible");
      case ERR_GLOBAL_VARIABLES_PROCESSING: return("Global variables processing error");
      case ERR_GLOBAL_VARIABLE_NOT_FOUND: return("Global variable not found");
      case ERR_FUNC_NOT_ALLOWED_IN_TESTING: return("Function is not allowed in testing mode");
      case ERR_FUNCTION_NOT_CONFIRMED: return("Function is not allowed for call");
      case ERR_SEND_MAIL_ERROR: return("Send mail error");
      case ERR_STRING_PARAMETER_EXPECTED: return("String parameter expected");
      case ERR_INTEGER_PARAMETER_EXPECTED: return("Integer parameter expected");
      case ERR_DOUBLE_PARAMETER_EXPECTED: return("Double parameter expected");
      case ERR_ARRAY_AS_PARAMETER_EXPECTED: return("Array as parameter expected");
      case ERR_HISTORY_WILL_UPDATED: return("Requested history data is in updating state");
      case ERR_TRADE_ERROR: return("Internal trade error");
      case ERR_RESOURCE_NOT_FOUND: return("Resource not found");
      case ERR_RESOURCE_NOT_SUPPORTED: return("Resource not supported");
      case ERR_RESOURCE_DUPLICATED: return("Duplicate resource");
      case ERR_INDICATOR_CANNOT_INIT: return("Custom indicator cannot initialize");
      case ERR_INDICATOR_CANNOT_LOAD: return("Cannot load custom indicator");
      case ERR_NO_HISTORY_DATA: return("No history data");
      case ERR_NO_MEMORY_FOR_HISTORY: return("No memory for history data");
      case ERR_NO_MEMORY_FOR_INDICATOR: return("Not enough memory for indicator calculation");
      case ERR_END_OF_FILE: return("End of file");
      case ERR_SOME_FILE_ERROR: return("Some file error");
      case ERR_WRONG_FILE_NAME: return("Wrong file name");
      case ERR_TOO_MANY_OPENED_FILES: return("Too many opened files");
      case ERR_CANNOT_OPEN_FILE: return("Cannot open file");
      case ERR_INCOMPATIBLE_FILEACCESS: return("Incompatible access to a file");
      case ERR_NO_ORDER_SELECTED: return("No order selected");
      case ERR_UNKNOWN_SYMBOL: return("Unknown symbol");
      case ERR_INVALID_PRICE_PARAM: return("Invalid price");
      case ERR_INVALID_TICKET: return("Invalid ticket");
      case ERR_TRADE_NOT_ALLOWED: return("Trade is not allowed. Enable checkbox \"Allow live trading\" in the Expert Advisor properties");
      case ERR_LONGS_NOT_ALLOWED: return("Longs are not allowed. Check the Expert Advisor properties");
      case ERR_SHORTS_NOT_ALLOWED: return("Shorts are not allowed. Check the Expert Advisor properties");
      case ERR_TRADE_EXPERT_DISABLED_BY_SERVER : return("Automated trading by Expert Advisors/Scripts disabled by trade server");
      case ERR_OBJECT_ALREADY_EXISTS: return("Object already exists");
      case ERR_UNKNOWN_OBJECT_PROPERTY: return("Unknown object property");
      case ERR_OBJECT_DOES_NOT_EXIST: return("Object does not exist");
      case ERR_UNKNOWN_OBJECT_TYPE: return("Unknown object type");
      case ERR_NO_OBJECT_NAME: return("No object name");
      case ERR_OBJECT_COORDINATES_ERROR: return("Object coordinates error");
      case ERR_NO_SPECIFIED_SUBWINDOW: return("No specified subwindow");
      case ERR_SOME_OBJECT_ERROR: return("Graphical object error");
      case ERR_CHART_PROP_INVALID: return("Unknown chart property");
      case ERR_CHART_NOT_FOUND: return("Chart not found");
      case ERR_CHARTWINDOW_NOT_FOUND: return("Chart subwindow not found");
      case ERR_CHARTINDICATOR_NOT_FOUND: return("Chart indicator not found");
      case ERR_SYMBOL_SELECT: return("Symbol select error");
      case ERR_NOTIFICATION_ERROR: return("Notification error");
      case ERR_NOTIFICATION_PARAMETER: return("Notification parameter error");
      case ERR_NOTIFICATION_SETTINGS: return("Notifications disabled");
      case ERR_NOTIFICATION_TOO_FREQUENT: return("Notification send too frequent");
      case ERR_FTP_NOSERVER: return("FTP server is not specified");
      case ERR_FTP_NOLOGIN : return("FTP login is not specified");
      case ERR_FTP_CONNECT_FAILED : return("FTP connection failed");
      case ERR_FTP_CLOSED: return("FTP connection closed");
      case ERR_FTP_CHANGEDIR: return("FTP path not found on server");
      case ERR_FTP_FILE_ERROR: return("File not found in the MQL4"+CharToString(92)+"Files directory to send on FTP server");
      case ERR_FTP_ERROR: return("Common error during FTP data transmission");
      case ERR_FILE_TOO_MANY_OPENED: return("Too many opened files");
      case ERR_FILE_WRONG_FILENAME: return("Wrong file name");
      case ERR_FILE_TOO_LONG_FILENAME: return("Too long file name");
      case ERR_FILE_CANNOT_OPEN: return("Cannot open file");
      case ERR_FILE_BUFFER_ALLOCATION_ERROR: return("Text file buffer allocation error");
      case ERR_FILE_CANNOT_DELETE: return("Cannot delete file");
      case ERR_FILE_INVALID_HANDLE: return("Invalid file handle (file closed or was not opened)");
      case ERR_FILE_WRONG_HANDLE: return("Wrong file handle (handle index is out of handle table)");
      case ERR_FILE_NOT_TOWRITE: return("File must be opened with FILE_WRITE flag");
      case ERR_FILE_NOT_TOREAD: return("File must be opened with FILE_READ flag");
      case ERR_FILE_NOT_BIN: return("File must be opened with FILE_BIN flag");
      case ERR_FILE_NOT_TXT: return("File must be opened with FILE_TXT flag");
      case ERR_FILE_NOT_TXTORCSV: return("File must be opened with FILE_TXT or FILE_CSV flag");
      case ERR_FILE_NOT_CSV: return("File must be opened with FILE_CSV flag");
      case ERR_FILE_READ_ERROR: return("File read error");
      case ERR_FILE_WRITE_ERROR: return("File write error");
      case ERR_FILE_BIN_STRINGSIZE: return("String size must be specified for binary file");
      case ERR_FILE_INCOMPATIBLE: return("Incompatible file (for string arrays-TXT, for others-BIN)");
      case ERR_FILE_IS_DIRECTORY: return("File is directory not file");
      case ERR_FILE_NOT_EXIST: return("File does not exist");
      case ERR_FILE_CANNOT_REWRITE: return("File cannot be rewritten");
      case ERR_FILE_WRONG_DIRECTORYNAME: return("Wrong directory name");
      case ERR_FILE_DIRECTORY_NOT_EXIST: return("Directory does not exist");
      case ERR_FILE_NOT_DIRECTORY: return("Specified file is not directory");
      case ERR_FILE_CANNOT_DELETE_DIRECTORY: return("Cannot delete directory");
      case ERR_FILE_CANNOT_CLEAN_DIRECTORY: return("Cannot clean directory");
      case ERR_FILE_ARRAYRESIZE_ERROR: return("Array resize error");
      case ERR_FILE_STRINGRESIZE_ERROR: return("String resize error");
      case ERR_FILE_STRUCT_WITH_OBJECTS: return("Structure contains strings or dynamic arrays");
      case ERR_WEBREQUEST_INVALID_ADDRESS: return("Invalid URL");
      case ERR_WEBREQUEST_CONNECT_FAILED: return("Failed to connect to specified URL");
      case ERR_WEBREQUEST_TIMEOUT: return("Timeout exceeded");
      case ERR_WEBREQUEST_REQUEST_FAILED: return("HTTP request failed");
      case ERR_USER_ERROR_FIRST: return("User defined errors start with this code");
#endif
      default: return("Unknown error");
     }
//---

  }
//+------------------------------------------------------------------+

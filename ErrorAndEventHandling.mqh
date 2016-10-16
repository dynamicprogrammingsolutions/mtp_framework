#include "Loader.mqh"

#define ERROR_AND_EVENT_HANDLING_H

#define TypeToString(__type__) EnumToString((ENUM_CLASS_NAMES)__type__)
#define CLASS_NAME(__obj__) EnumToString((ENUM_CLASS_NAMES)__obj__.Type())
#define Conc StringConcatenate

#define NOTIFY_PRINT(__type__,__message__) Print(__type__," at ",__FILE__,",",__LINE__,",",__FUNCTION__,":",__message__);
#define NOTIFY_ALERT(__type__,__message__) Alert(__type__," at ",__FILE__,",",__LINE__,",",__FUNCTION__,":",__message__);

#define NOTIFY_PRINT_SIMPLE(__type__,__message__) Print(__type__," in ",__FUNCTION__,":",__message__);
#define NOTIFY_ALERT_SIMPLE(__type__,__message__) Alert(__type__," in ",__FUNCTION__,":",__message__);

#define PRINT_FATAL(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#define ALERT_FATAL(__type__,__message__) NOTIFY_ALERT(__type__,__message__);

// Error

#ifdef EError_Print
#define PRINT_ERROR(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#else
#ifdef EError_Print_Param
#define PRINT_ERROR(__type__,__message__) if (EError_Print_Param) NOTIFY_PRINT(__type__,__message__);
#else
#define PRINT_ERROR(__type__,__message__)
#endif
#endif

#ifdef EError_Alert
#define ALERT_ERROR(__type__,__message__) NOTIFY_ALERT(__type__,__message__);
#else
#ifdef EError_Alert_Param
#define ALERT_ERROR(__type__,__message__) if (EError_Print_Param) NOTIFY_ALERT(__type__,__message__);
#else
#define ALERT_ERROR(__type__,__message__)
#endif
#endif

//Warning

#ifdef EWarning_Print
#define PRINT_WARNING(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#else
#ifdef EWarning_Print_Param
#define PRINT_WARNING(__type__,__message__) if (EWarning_Print_Param) NOTIFY_PRINT(__type__,__message__);
#else
#define PRINT_WARNING(__type__,__message__)
#endif
#endif

#ifdef EWarning_Alert
#define ALERT_WARNING(__type__,__message__) NOTIFY_ALERT(__type__,__message__);
#else
#ifdef EWarning_Alert_Param
#define ALERT_WARNING(__type__,__message__) if (EWarning_Print_Param) NOTIFY_ALERT(__type__,__message__);
#else
#define ALERT_WARNING(__type__,__message__)
#endif
#endif


//Notice

#ifdef ENotice_Print
#define PRINT_NOTICE(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#else
#ifdef ENotice_Print_Param
#define PRINT_NOTICE(__type__,__message__) if (ENotice_Print_Param) NOTIFY_PRINT(__type__,__message__);
#else
#define PRINT_NOTICE(__type__,__message__)
#endif
#endif

#ifdef ENotice_Alert
#define ALERT_NOTICE(__type__,__message__) NOTIFY_ALERT(__type__,__message__);
#else
#ifdef ENotice_Alert_Param
#define ALERT_NOTICE(__type__,__message__) if (ENotice_Print_Param) NOTIFY_ALERT(__type__,__message__);
#else
#define ALERT_NOTICE(__type__,__message__)
#endif
#endif

//Info

#ifdef EInfo_Print
#define PRINT_INFO(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#else
#ifdef EInfo_Print_Param
#define PRINT_INFO(__type__,__message__) if (EInfo_Print_Param) NOTIFY_PRINT(__type__,__message__);
#else
#define PRINT_INFO(__type__,__message__)
#endif
#endif

#ifdef EInfo_Alert
#define ALERT_INFO(__type__,__message__) NOTIFY_ALERT(__type__,__message__);
#else
#ifdef EInfo_Alert_Param
#define ALERT_INFO(__type__,__message__) if (EInfo_Print_Param) NOTIFY_ALERT(__type__,__message__);
#else
#define ALERT_INFO(__type__,__message__)
#endif
#endif

//Debug

#ifdef EDebug_Print
#define PRINT_DEBUG(__type__,__message__) NOTIFY_PRINT(__type__,__message__);
#else
#ifdef EDebug_Print_Param
#define PRINT_DEBUG(__type__,__message__) if (EDebug_Print_Param) NOTIFY_PRINT(__type__,__message__);
#else
#define PRINT_DEBUG(__type__,__message__)
#endif
#endif

#ifdef EDebug_Alert
#define ALERT_DEBUG(__type__,__message__) NOTIFY_ALERT(__type__,__message__);
#else
#ifdef EDebug_Alert_Param
#define ALERT_DEBUG(__type__,__message__) if (EDebug_Print_Param) NOTIFY_ALERT(__type__,__message__);
#else
#define ALERT_DEBUG(__type__,__message__)
#endif
#endif

// 

#define EFatal(__message__) { PRINT_FATAL("Fatal",__message__); ALERT_FATAL("Fatal",__message__); }
#define EError(__message__) { PRINT_ERROR("Error",__message__); ALERT_ERROR("Error",__message__); }
#define EWarning(__message__) { PRINT_WARNING("Warning",__message__); ALERT_WARNING("Warning",__message__); }
#define ENotice(__message__) { PRINT_NOTICE("Notice",__message__); ALERT_NOTICE("Notice",__message__); }
#define EInfo(__message__) { PRINT_INFO("Info",__message__); ALERT_INFO("Info",__message__); }
#define EDebug(__message__) { PRINT_DEBUG("Debug",__message__); ALERT_DEBUG("Debug",__message__); }

#define EFatal_ EFatal("")
#define EError_ EError("")

#define EError_Ret(__ret__) { EError("") return __ret__; }

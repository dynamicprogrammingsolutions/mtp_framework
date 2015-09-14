//
enum ENUM_CLASS_NAMES {
   classNone,
#include "__classnames.mqh"
#ifdef CUSTOM_CLASSES
   CUSTOM_CLASSES
#endif
   classLast
};
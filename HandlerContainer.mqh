//
#include "Loader.mqh"

class CHandlerContainerItem : private CObject
{
public:
   ENUM_CLASS_NAMES handled_class;
   CObject* handler;
   CHandlerContainerItem(ENUM_CLASS_NAMES _handled_class, CObject* _handler)
   {
      handled_class = _handled_class;
      handler = _handler;
   }
};

class CHandlerContainer : public CArrayObj
{
public:
   void Add(ENUM_CLASS_NAMES handled_class, CObject* handler)
   {
      CHandlerContainerItem* handleritem = FindHandler(handled_class);
      if (handleritem == NULL) this.Add(new CHandlerContainerItem(handled_class,handler));
      else handleritem.handler = handler;
   }
   CObject* GetHandler(ENUM_CLASS_NAMES handled_class)
   {
      for (int i = 0; i < Total(); i++) {
      	CHandlerContainerItem* item = At(i);
      	if (item.handled_class == handled_class) return (CObject*)item.handler;
      }
      return NULL;
   }
   CHandlerContainerItem* FindHandler(ENUM_CLASS_NAMES handled_class)
   {
      for (int i = 0; i < Total(); i++) {
      	CHandlerContainerItem* item = At(i);
      	if (item.handled_class == handled_class) return item;
      }
      return NULL;
   }
   void InitalizeHandlers()
   {
      for (int i = 0; i < Total(); i++) {
      	CHandlerContainerItem* item = At(i);
      	CAppObject* handler = item.handler;
      	if (!handler.Initalized()) {
            Print("Initalizing Handler of '",EnumToString(item.handled_class),"': '",EnumToString((ENUM_CLASS_NAMES)handler.Type()),"'");
            handler.Initalize();
            handler.SetInitalized();
         } else {
            Print("Handler Already Initalized: ",EnumToString((ENUM_CLASS_NAMES)item.handler.Type()));            
         }
      }
   }
   bool IsRegistered(ENUM_CLASS_NAMES handled_class)
   {
      return (this.GetHandler(handled_class) != NULL);
   }
};
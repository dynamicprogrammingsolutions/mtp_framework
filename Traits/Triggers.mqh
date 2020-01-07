//

#define TRIGGERP(__signal__,__parameter__) (APP.triggers.Send(__signal__,__parameter__))

#define TRIGGERPR(__signal__,__parameter__) (APP.triggers.SendR(__signal__,__parameter__))

#define TRIGGERC(__signal__,__parameter__) (APP.triggers.Send(__signal__,__parameter__,true))

#define TRIGGERCR(__signal__,__parameter__) (APP.triggers.SendR(__signal__,__parameter__,true))

#define TRIGGER(__signal__) (APP.triggers.SendR(__signal__,GetPointer(this)))

#define LISTEN(__signal__,__functionid__) APP.triggers.Register(__signal__,GetPointer(this),__functionid__)

#define HANDLER(__signal__,__callback__,__id__) APP.triggers.Register(__signal__,__callback__,__id__)

#define InitListen CObject* obj = NULL; callback(-1,obj);

#define ListenTo5Triggers(firstid,object,trigger1,trigger2,trigger3,trigger4,trigger5) switch(id) { case -1: LISTEN(object::trigger1,0); LISTEN(object::trigger2,1); LISTEN(object::trigger3,2); LISTEN(object::trigger4,3); LISTEN(object::trigger5,4); break; case firstid+0: return trigger1(obj); case firstid+1: return trigger2(obj); case firstid+2: return trigger3(obj); case firstid+3: return trigger4(obj); case firstid+4: return trigger5(obj); }

#define CALLBACK(__functions__) bool callback(const int id, CObject* obj) { switch(id) { __functions__ } return true; }

#define CALLBACKP(__parent__,__functions__) bool callback(const int id, CObject* obj) { switch(id) { __functions__ } return __parent__::callback(id,obj); }

#define CBFUNC(__id__,__name__) case __id__: return __name__(obj);

#define CBFUNC_POBJ(__id__,__name__) case __id__: return __name__(CheckPointer(obj)!=POINTER_INVALID?obj:NULL);

#define CBFUNC_RETOBJ(__id__,__name__) case __id__: obj = __name__(); return true;

#define CBFUNC_POBJ_RETOBJ(__id__,__name__) case __id__: obj = __name__(CheckPointer(obj)!=POINTER_INVALID?obj:NULL); return true;

#define CBFUNC_VOID(__id__,__name__) case __id__: __name__(); return true;

/*

Example:

   virtual void Initalize()
   {
      LISTEN(COrderBase::EventStateChange,1);
   }
   
   CALLBACK(
      CBFUNC(1,StateChange)
   )
   
   bool StateChange(COrder* order)
   {
      Print("order "+order.ticket+" state "+EnumToString(order.State()));
   }

*/


/*
#define ListenTo5Triggers(firstid,object,trigger1,trigger2,trigger3,trigger4,trigger5)
    switch(id) {
      case -1:
         LISTEN(object::trigger1,firstid+0);
         LISTEN(object::trigger2,firstid+1);
         LISTEN(object::trigger3,firstid+2);
         LISTEN(object::trigger4,firstid+3);
         LISTEN(object::trigger5,firstid+4);
         break;
      case firstid+0: return trigger1(obj);
      case firstid+1: return trigger2(obj);
      case firstid+2: return trigger3(obj);
      case firstid+3: return trigger4(obj);
      case firstid+4: return trigger5(obj);
   }
*/
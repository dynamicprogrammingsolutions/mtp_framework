//

#include "..\Loader.mqh"

#define TRIGGER(__signal__) App().trigger.TriggerBoolOr(this.Type(),__signal__,MakeWAppObject(GetPointer(this)))
#define LISTEN(__classtype__,__signal__,__functionid__) App().trigger.Register(__classtype__,__signal__,this,__functionid__)
#define HANDLER(__classtype__,__signal__,__object__,__functionid__) App().trigger.Register(__classtype__,__signal__,__object__,__functionid__)

#define TRIGGER_CONFIRM(__class__,__trigger__) App().trigger.TriggerBoolOr(__class__,__trigger__)
#define TRIGGER_CONFIRM_P(__class__,__trigger__,__param__) App().trigger.TriggerBoolOr(__class__,__trigger__,__param__)
/*#define TRIGGER_CONFIRM_SP(__trigger__,__param__) App().trigger.TriggerBoolOr(this.Type(),__trigger__,MakeAppObject(__param__))
#define TRIGGER_CONFIRM_WP(__trigger__,__param__) App().trigger.TriggerBoolOr(this.Type(),__trigger__,MakeWAppObject(__param__))*/
#define TRIGGER_CONFIRM_S(__class__,__trigger__) App().trigger.TriggerBoolOr(__class__,__trigger__,MakeWAppObject(this))

#define TRIGGER_VOID(__class__,__trigger__) App().trigger.Trigger(__class__,__trigger__)
#define TRIGGER_BOOL(__class__,__trigger__) App().trigger.TriggerBool(__class__,__trigger__)
#define TRIGGER_BOOL_AND(__class__,__trigger__) App().trigger.TriggerBoolAnd(__class__,__trigger__)
#define TRIGGER_BOOL_OR(__class__,__trigger__) App().trigger.TriggerBoolOr(__class__,__trigger__)
#define TRIGGER_INT(__class__,__trigger__) App().trigger.TriggerInt(__class__,__trigger__)
#define TRIGGER_DOUBLE(__class__,__trigger__) App().trigger.TriggerDouble(__class__,__trigger__)
#define TRIGGER_OBJ(__class__,__trigger__) App().trigger.TriggerObj(__class__,__trigger__)

#define TRIGGER_VOID_P(__class__,__trigger__,__param__) App().trigger.Trigger(__class__,__trigger__,__param__)
#define TRIGGER_BOOL_P(__class__,__trigger__,__param__) App().trigger.TriggerBool(__class__,__trigger__,__param__)
#define TRIGGER_BOOL_AND_P(__class__,__trigger__,__param__) App().trigger.TriggerBoolAnd(__class__,__trigger__,__param__)
#define TRIGGER_BOOL_OR_P(__class__,__trigger__,__param__) App().trigger.TriggerBoolOr(__class__,__trigger__,__param__)
#define TRIGGER_INT_P(__class__,__trigger__,__param__) App().trigger.TriggerInt(__class__,__trigger__,__param__)
#define TRIGGER_DOUBLE_P(__class__,__trigger__,__param__) App().trigger.TriggerDouble(__class__,__trigger__,__param__)
#define TRIGGER_OBJ_P(__class__,__trigger__,__param__) App().trigger.TriggerObj(__class__,__trigger__,__param__)

#define CALLBACK_VOID(__functions__) virtual void callback(const int id) { switch(id) { __functions__ } return; }
#define CALLBACK_BOOL(__functions__) virtual bool callback_bool(const int id) { switch(id) { __functions__ } return false; }
#define CALLBACK_INT(__functions__) virtual int callback_int(const int id) { switch(id) { __functions__ } return 0; }
#define CALLBACK_DOUBLE(__functions__) virtual double callback_double(const int id) { switch(id) { __functions__ } return 0; }
#define CALLBACK_OBJ(__functions__) virtual PAppObject callback_obj(const int id) { switch(id) { __functions__ } return MakeAppObject(); }

#define CALLBACK_VOID_P(__parameter__,__functions__) virtual void callback(const int id, __parameter__) { switch(id) { __functions__ } return; }
#define CALLBACK_BOOL_P(__parameter__,__functions__) virtual bool callback_bool(const int id, __parameter__) { switch(id) { __functions__ } return false; }
#define CALLBACK_INT_P(__parameter__,__functions__) virtual int callback_int(const int id, __parameter__) { switch(id) { __functions__ } return 0; }
#define CALLBACK_DOUBLE_P(__parameter__,__functions__) virtual double callback_double(const int id, __parameter__) { switch(id) { __functions__ } return 0; }
#define CALLBACK_OBJ_P(__parameter__,__functions__) virtual PAppObject callback_obj(const int id, __parameter__) { switch(id) { __functions__ } return MakeAppObject(); }

#define CBFUNC_VOID(__id__,__call__) case __id__: __call__(); break;
#define CBFUNC_BOOL(__id__,__call__) case __id__: return __call__(); break;
#define CBFUNC_INT(__id__,__call__) case __id__: return __call__(); break;
#define CBFUNC_DOUBLE(__id__,__call__) case __id__: return __call__(); break;
#define CBFUNC_OBJ(__id__,__call__) case __id__: return MakeAppObject(__call__()); break;

#define CBFUNC_VOID_P(__id__,__call__) case __id__: __call__; break;
#define CBFUNC_BOOL_P(__id__,__call__) case __id__: return __call__; break;
#define CBFUNC_INT_P(__id__,__call__) case __id__: return __call__; break;
#define CBFUNC_DOUBLE_P(__id__,__call__) case __id__: return __call__; break;
#define CBFUNC_OBJ_P(__id__,__call__) case __id__: return __call__; break;

/*
#define HANDLER(__signal__,__callback__,__id__) APP.triggers.Register(__signal__,__callback__,__id__)

#define InitListen CObject* obj = NULL; callback(-1,obj);

#define ListenTo5Triggers(firstid,object,trigger1,trigger2,trigger3,trigger4,trigger5) switch(id) { case -1: LISTEN(object::trigger1,0); LISTEN(object::trigger2,1); LISTEN(object::trigger3,2); LISTEN(object::trigger4,3); LISTEN(object::trigger5,4); break; case firstid+0: return trigger1(obj); case firstid+1: return trigger2(obj); case firstid+2: return trigger3(obj); case firstid+3: return trigger4(obj); case firstid+4: return trigger5(obj); }

#define CALLBACK(__functions__) bool callback(const int id, CObject*& obj) { switch(id) { __functions__ } return true; }

#define CALLBACKP(__parent__,__functions__) bool callback(const int id, CObject*& obj) { switch(id) { __functions__ } return __parent__::callback(id,obj); }

#define CBFUNC(__id__,__name__) case __id__: return __name__(obj);

#define CBFUNC_2NDPARAM(__id__,__name__,__2ndparam__) case __id__: return __name__(obj,__2ndparam__);

#define CBFUNC_POBJ(__id__,__name__) case __id__: return __name__(CheckPointer(obj)!=POINTER_INVALID?obj:NULL);

#define CBFUNC_RETOBJ(__id__,__name__) case __id__: obj = __name__(); return true;

#define CBFUNC_POBJ_RETOBJ(__id__,__name__) case __id__: obj = __name__(CheckPointer(obj)!=POINTER_INVALID?obj:NULL); return true;

#define CBFUNC_VOID(__id__,__name__) case __id__: __name__(); return true;
*/

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
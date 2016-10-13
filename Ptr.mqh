#include "Loader.mqh"

#define PTR_H
template<typename T>

#ifndef ISSET
#define ISSET(__obj__) (CheckPointer(__obj__)!=POINTER_INVALID)
#endif

class CSharedObj {
   
private:
   T *obj;
   int refcount;
   
public:
   CSharedObj(T *_obj)
   {
      obj = _obj;
   }
   ~CSharedObj()
   {
      delete obj;
   }
   CSharedObj* RefAdd()
   {
      refcount++;
      return GetPointer(this);
   }
   CSharedObj* RefDel()
   {
      refcount--;
      return GetPointer(this);
   }
   void RefClean()
   {
      if (refcount <= 0) {
         Print("delete object type "+EnumToString((ENUM_CLASS_NAMES)obj.Type()));
         delete GetPointer(this);
      }
   }
   int RefCount()
   {
      return refcount;
   }
   T *Obj()
   {
      return obj;
   }
};

template<typename T>
class shared_ptr : public CObject
{
private:
   CSharedObj<CObject> *sharedobj;
public:
   shared_ptr()
   {
      
   }
   shared_ptr(const shared_ptr<T> &ptr)
   {
      sharedobj = ptr.sharedobj.RefAdd();
   }

   shared_ptr(CSharedObj<CObject> *obj)
   {
      sharedobj = obj;
      sharedobj.RefAdd();
   }
   shared_ptr(CSharedObj<CObject> &obj)
   {
      sharedobj = GetPointer(obj);
      sharedobj.RefAdd();
   }
   shared_ptr(T *obj)
   {
      sharedobj = (new CSharedObj<CObject>(obj)).RefAdd();
   }
   ~shared_ptr()
   {
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
   }
   template<typename T1>
   void assign(shared_ptr<T1> &ptr)
   {
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = ptr.obj_shared().RefAdd();
   }
   void assign(CSharedObj<CObject> *obj)
   {
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = obj.RefAdd();
   }
   void assign(T *obj)
   {
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = (new CSharedObj<CObject>(obj)).RefAdd();
   }
   int refcount()
   {
      if (ISSET(sharedobj))
         return sharedobj.RefCount();
      else
         return -1;
   }
   bool isset()
   {
      return ISSET(sharedobj);
   }
   CSharedObj<CObject> *obj_shared() const
   {
      if (ISSET(sharedobj))
         return sharedobj;
      else 
         return NULL;
   }
   T *obj()
   {
      if (ISSET(sharedobj)) {
         return sharedobj.Obj();
      } else
         return NULL;
   }
   
   static shared_ptr<T> make_shared(T *obj)
   {
      shared_ptr<T> ptr(obj);
      return ptr;
   }

};
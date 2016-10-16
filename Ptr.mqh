#include "Loader.mqh"

#define PTR_H
template<typename T>

#ifndef ISSET
#define ISSET(__obj__) (CheckPointer(__obj__)!=POINTER_INVALID)
#define ISNSET(__obj__) (CheckPointer(__obj__)==POINTER_INVALID)
#endif

enum ENUM_PTR_TYPE
{
   ptrNone,
   ptrShared,
   ptrUnique,
   ptrWeak
};

template<typename T>
class base_ptr : public CObject
{
protected:
   ENUM_PTR_TYPE ptrtype;
   T *sharedobj;
public:
   base_ptr()
   {
      
   }
   
   base_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptr.ptrtype;
      copy(ptr);      
   }
   
   ~base_ptr()
   {
      destroy();
   }
   
   void copy(const base_ptr<T> &ptr)
   {
      switch(ptrtype) {
         case ptrShared:
            sharedobj = ptr.sharedobj;
            if (ISSET(sharedobj)) sharedobj.RefAdd();
            break;
         case ptrUnique:
            sharedobj = ptr.sharedobj;
            if (ISSET(sharedobj)) sharedobj.UniqueLock();
         case ptrWeak:
            sharedobj = ptr.sharedobj;
      }
   }
   
   void destroy()
   {
      switch(ptrtype) {
         case ptrUnique:
            if (ISSET(sharedobj)) {
               sharedobj.UniqueRelease();
               sharedobj.UniqueDelete();
               sharedobj = NULL;
            }
            break;
         case ptrShared:
            if (ISSET(sharedobj)) {
               sharedobj.RefDel().RefClean();
               sharedobj = NULL;
            }
            break;
         case ptrWeak:
            sharedobj = NULL;
            break;
      }
   }
   
   /*template<typename T1>
   void assign(base_ptr<T1> &ptr)
   {
      switch(ptrtype) {
         case ptrShared:
            ptr.get().RefAdd();
            if (ISSET(sharedobj)) {
               sharedobj.RefDel().RefClean();
            }
            sharedobj = ptr.get();
   }
   void reset(T *obj)
   {
      obj.RefAdd();
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = obj;
   }
   T *detach()
   {
      if (ISSET(sharedobj)) {
         T *temp = sharedobj;
         sharedobj = NULL;
         temp.RefDel();
         return temp;
      } else {
         return NULL;
      }
   }*/
   
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
   
   bool isnset()
   {
      return ISNSET(sharedobj);
   }
   
   T *get() const
   {
      if (ISSET(sharedobj)) {
         return sharedobj;
      } else
         return NULL;
   }
   
   virtual bool      Save(const int file_handle)                         
   {
      if (ISSET(sharedobj))
         return sharedobj.Save(file_handle);
      else
         return true;
   }
   
   virtual bool      Load(const int file_handle)
   {
      if (ISSET(sharedobj))
         return sharedobj.Load(file_handle);
      else
         return true;
   }

   virtual int       Type(void)
   {
      if (ISSET(sharedobj))
         return sharedobj.Type();
      else
         return 0;
   }

   virtual int       Compare(const CObject *node,const int mode=0) const
   {
      if (ISSET(sharedobj))
         return sharedobj.Compare(node,mode);
      else
         return 0;
   }

};

template<typename T>
class shared_ptr : public base_ptr<T>
{
public:
   shared_ptr()
   {
      ptrtype = ptrShared;
   }
   shared_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrShared;
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }
   /*shared_ptr(const unique_ptr<T> &ptr)
   {
      ptrtype = ptrShared;
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }
   shared_ptr(const shared_ptr<T> &ptr)
   {
      ptrtype = ptrShared;
      sharedobj = ptr.sharedobj;
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }
   shared_ptr(const weak_ptr<T> &ptr)
   {
      ptrtype = ptrShared;
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }*/
   shared_ptr(T *obj)
   {
      ptrtype = ptrShared;
      sharedobj = obj;
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }
   shared_ptr(T &obj)
   {
      ptrtype = ptrShared;
      sharedobj = GetPointer(obj);
      if (ISSET(sharedobj)) sharedobj.RefAdd();
   }
   template<typename T1>
   void assign(base_ptr<T1> &ptr)
   {
      ptr.get().RefAdd();
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = ptr.get();
   }
   void reset(T *obj)
   {
      obj.RefAdd();
      if (ISSET(sharedobj)) {
         sharedobj.RefDel().RefClean();
      }
      sharedobj = obj;
   }
   T *detach()
   {
      if (ISSET(sharedobj)) {
         T *temp = sharedobj;
         sharedobj = NULL;
         temp.RefDel();
         return temp;
      } else {
         return NULL;
      }
   }

   static shared_ptr<T> make_shared(T &obj)
   {
      //shared_ptr<T> ptr(obj);
      return obj;
   }
   
   static shared_ptr<T> make_shared(T *obj)
   {
      //shared_ptr<T> ptr(obj);
      return obj;
   }

   static shared_ptr<T> make_shared()
   {
      //shared_ptr<T> ptr(obj);
      return NULL;
   }

   template<typename T1>
   static shared_ptr<T> make_shared(shared_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static shared_ptr<T> make_shared(unique_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static shared_ptr<T> make_shared(weak_ptr<T1> &ptr)
   {
      return ptr.get();
   }
};

template<typename T>
class unique_ptr : public base_ptr<T>
{
public:
   unique_ptr()
   {
      ptrtype = ptrUnique;      
   }
   unique_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrUnique;      
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }
   /*unique_ptr(const unique_ptr<T> &ptr)
   {
      ptrtype = ptrUnique;      
      sharedobj = ptr.sharedobj;
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }
   unique_ptr(const shared_ptr<T> &ptr)
   {
      ptrtype = ptrUnique;      
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }
   unique_ptr(const weak_ptr<T> &ptr)
   {
      ptrtype = ptrUnique;      
      sharedobj = ptr.get();
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }*/
   unique_ptr(T *obj)
   {
      ptrtype = ptrUnique;      
      sharedobj = obj;
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }
   unique_ptr(T &obj)
   {
      ptrtype = ptrUnique;      
      sharedobj = GetPointer(obj);
      if (ISSET(sharedobj)) sharedobj.UniqueLock();
   }
   
   template<typename T1>
   void assign(unique_ptr<T1> &ptr)
   {
      if (ISSET(sharedobj)) {
         sharedobj.UniqueRelease();
      }
      ptr.get().UniqueLock();
      if (ISSET(sharedobj)) {
         sharedobj.UniqueDelete();
      }
      sharedobj = ptr.get();
   }
   void reset(T *obj)
   {
      if (ISSET(sharedobj)) {
         sharedobj.UniqueRelease();
      }
      obj.UniqueLock();
      if (ISSET(sharedobj)) {
         sharedobj.UniqueDelete();
      }
      sharedobj = obj;
   }
   T *detach()
   {
      if (ISSET(sharedobj)) {
         T *temp = sharedobj;
         sharedobj = NULL;
         temp.UniqueRelease();
         return temp;
      } else {
         return NULL;
      }
   }

   static unique_ptr<T> make_unique(T &obj)
   {
      //shared_ptr<T> ptr(obj);
      return obj;
   }
   
   static unique_ptr<T> make_unique(T *obj)
   {
      //shared_ptr<T> ptr(obj);
      return obj;
   }

   static unique_ptr<T> make_unique()
   {
      //shared_ptr<T> ptr(obj);
      return NULL;
   }

   template<typename T1>
   static unique_ptr<T> make_unique(shared_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static unique_ptr<T> make_unique(unique_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static unique_ptr<T> make_unique(weak_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static unique_ptr<T> convert(T1 &ptr)
   {
      return ptr.get();
   }
   
};


template<typename T>
class weak_ptr : public base_ptr<T>
{
public:
   weak_ptr()
   {
      ptrtype = ptrWeak;            
   }
   weak_ptr(const base_ptr<T> &ptr)
   {
      ptrtype = ptrWeak;            
      sharedobj = ptr.get();
   }
   /*weak_ptr(const unique_ptr<T> &ptr)
   {
      ptrtype = ptrWeak;            
      sharedobj = ptr.get();
   }
   weak_ptr(const shared_ptr<T> &ptr)
   {
      ptrtype = ptrWeak;            
      sharedobj = ptr.get();
   }
   weak_ptr(const weak_ptr<T> &ptr)
   {
      ptrtype = ptrWeak;            
      sharedobj = ptr.sharedobj;
   }*/
   weak_ptr(T *obj)
   {
      ptrtype = ptrWeak;            
      sharedobj = obj;
   }
   weak_ptr(T &obj)
   {
      ptrtype = ptrWeak;            
      sharedobj = GetPointer(obj);
   }
   
   template<typename T1>
   void assign(weak_ptr<T1> &ptr)
   {
      sharedobj = ptr.get();
   }
   void reset(T *obj)
   {
      sharedobj = obj;
   }
   T *detach()
   {
      if (ISSET(sharedobj)) {
         T *temp = sharedobj;
         sharedobj = NULL;
         return temp;
      } else {
         return NULL;
      }
   }
   
   static weak_ptr<T> make_weak(T &obj)
   {
      return obj;
   }
   
   static weak_ptr<T> make_weak(T *obj)
   {
      return obj;
   }

   static weak_ptr<T> make_weak()
   {
      return NULL;
   }

   template<typename T1>
   static weak_ptr<T> make_weak(shared_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static weak_ptr<T> make_weak(unique_ptr<T1> &ptr)
   {
      return ptr.get();
   }

   template<typename T1>
   static weak_ptr<T> make_weak(weak_ptr<T1> &ptr)
   {
      return ptr.get();
   }

};
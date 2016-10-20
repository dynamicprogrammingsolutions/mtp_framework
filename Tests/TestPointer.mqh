#include "Loader.mqh"
#property strict

class CTestChildAppObject : public CAppObject
{

};

class CTestPointer : public CTestBase
{
public:
   CAppObject *temp1,*temp2,*temp3;

template<typename T>
bool AssertPtr(const base_ptr<T> &ptr,const int ref_count,const bool owned, const int id)
{
   bool ret = true;
   ret &= AssertEqual(ptr.isset(),true,"isset",false);
   if (ptr.isset()) {
      ret &= AssertEqual(ptr.refcount(),ref_count,"refcount",false);
      ret &= AssertEqual(ptr.owned(),(bool)owned,"owned",false);
      ret &= AssertNotEqualEnum(CheckPointer(ptr.get()),POINTER_INVALID,"CheckPointer(ptr.get())",false);
      ret &= AssertEqual(ptr.get().RefCount(),ref_count,"get().refcount",false);
      if (id > 0)
         ret &= AssertEqual(ptr.get().Id(),id,"get().id",false);
   }
   if (ret) {
      return true;
   }
   return false;
}

template<typename T>
bool AssertPtr(const base_ptr<T> &ptr,const bool is_set, const int ref_count = 0,const bool owned = false, const int id = 0)
{
   bool ret = true;
   ret &= AssertEqual(ptr.isset(),is_set,"isset",false);
   if (ptr.isset()) {
      ret &= AssertEqual(ptr.refcount(),ref_count,"refcount",false);
      ret &= AssertEqual(ptr.owned(),(bool)owned,"owned",false);
      ret &= AssertEqual(ptr.get().RefCount(),ref_count,"get().refcount",false);
      if (!is_set && id > 0)
         ret &= AssertEqual(ptr.get().Id(),id,"get().id",false);
   }
   if (ret) {
      return true;
   }
   return false;
}

bool AssertObject(const CAppObject *obj, const bool is_set, const int ref_count = 0, const bool owned = false, const int id = 0)
{
   bool ret = true;
   ret &= AssertEqual(isset(obj),is_set,"isset",false);
   if (isset(obj)) {
      ret &= AssertEqual(obj.RefCount(),ref_count,"refcount",false);
      ret &= AssertEqual(obj.Owned(),(bool)owned,"owned",false);
      if (!is_set && id > 0)
         ret &= AssertEqual(obj.Id(),id,"id",false);
   }
   if (ret) {
      return true;
   }
   return false;
}

bool AssertObjectNULL(const CAppObject *obj)
{
   bool ret = true;
   ret &= AssertEqual(obj,(CAppObject*)NULL,"obj",false);
   if (isset(obj)) {
      ret &= AssertEqual(obj.RefCount(),0,"refcount",false);
      ret &= AssertEqual(obj.Owned(),false,"owned",false);
      ret &= AssertEqual(obj.Id(),0,"id",false);
   }
   if (ret) {
      return true;
   }
   return false;
}

void TestSharedPtrConstructors()
{
   {
      TestName("TEST: construct shared_ptr from builtin pointer");
      // All of the following initialization is valid and equivalent
      {
         CAppObject *builtin_ptr1 = new CAppObject();
         shared_ptr<CAppObject> ptr1(builtin_ptr1);   
         AssertPtr(ptr1,1,false,builtin_ptr1.Id());
      }
      {
         CAppObject *builtin_ptr1 = new CAppObject();
         shared_ptr<CAppObject> ptr1 = builtin_ptr1;   
         AssertPtr(ptr1,1,false,builtin_ptr1.Id());
      }
      {
         shared_ptr<CAppObject> ptr1(new CAppObject());   
         AssertPtr(ptr1,1,false,0);
      }
      {
         shared_ptr<CAppObject> ptr1 = new CAppObject();   
         AssertPtr(ptr1,1,false,0);
      }
   }
   
   {
      TestName("TEST Warning: construct shared_ptr from pointer to builtin object (DO NOT DO THIS)");
      CAppObject builtin_obj1;
      shared_ptr<CAppObject> ptr2(GetPointer(builtin_obj1));
      AssertPtr(ptr2,1,false,builtin_obj1.Id());
      ptr2.detach();
      AssertWarning();
   }
    
   {   
      // Compilation Error:
      /*
      TestName("construct shared_ptr from unique_ptr");
      unique_ptr<CAppObject> tmpunique(new CAppObject());
      shared_ptr<CAppObject> ptr3(tmpunique);
      AssertPtr(ptr3,1,true,tmpunique.get().Id());
      */
   }
   
   {
      TestName("TEST Error: construct shared_ptr from unique_ptr");
      unique_ptr<CAppObject> tmpunique(new CAppObject());
      shared_ptr<CAppObject> ptr3(tmpunique.get());
      AssertPtr(ptr3,false);
      AssertError();
   }
   
   {
      TestName("TEST: construct shared_ptr from shared_ptr");
      shared_ptr<CAppObject> tmpshared(new CAppObject());
      shared_ptr<CAppObject> ptr4(tmpshared);
      AssertPtr(ptr4,2,false,tmpshared.get().Id());
   }
   
   {
      TestName("TEST: construct shared_ptr from weak_ptr");
      weak_ptr<CAppObject> tmpweak(new CAppObject());
      shared_ptr<CAppObject> ptr5(tmpweak);
      AssertPtr(ptr5,1,false,tmpweak.get().Id());
   }
   
   {
      TestName("TEST Error: construct shared_ptr from weak_ptr that was initalized from unique ptr");
      unique_ptr<CAppObject> tmpunique1(new CAppObject);
      weak_ptr<CAppObject> tmpweak2(tmpunique1);
      shared_ptr<CAppObject> ptr7(tmpweak2);
      AssertPtr(ptr7,false);
      AssertError();
   }

}


void TestUniquePtrConstructors()
{
   { 
      TestName("TEST: construct unique_ptr from builtin pointer");
      CAppObject *builtin_ptr1 = new CAppObject();
      unique_ptr<CAppObject> ptr1(builtin_ptr1);   
      AssertPtr(ptr1,0,true,builtin_ptr1.Id());
   }
   
   {
      // Compilation Error:
      /*
      TestName("construct unique_ptr from builtin object (DO NOT DO THIS)");
      CAppObject builtin_obj1;
      unique_ptr<CAppObject> ptr2(builtin_obj1);
      AssertPtr(ptr2,0,true,builtin_obj1.Id());
      ptr2.detach();
      */
   }
    
   {   
      TestName("TEST Warning: construct unique_ptr from pointer to builtin object");
      CAppObject builtin_obj1;
      unique_ptr<CAppObject> ptr2(GetPointer(builtin_obj1));
      AssertPtr(ptr2,0,true,builtin_obj1.Id());
      ptr2.detach();
      AssertWarning();
   }
   
   {
      //Compilation Error:
      /*
      unique_ptr<CAppObject> tmpunique(new CAppObject());   
      TestName("construct unique_ptr from unique_ptr (DO NOT DO THIS)");
      unique_ptr<CAppObject> ptr3(tmpunique);
      AssertPtr(ptr3,0,true,tmpunique.get().Id());
      ptr3.detach();
      */
   }
   
   {
      TestName("TEST Error: construct unique_ptr from object owned by unique_ptr (DO NOT DO THIS)");
      unique_ptr<CAppObject> tmpunique(new CAppObject());   
      unique_ptr<CAppObject> ptr3(tmpunique.get());
      AssertPtr(ptr3,false);
      AssertError();
   }
   
   {
      TestName("TEST Error: construct unique_ptr from shared_ptr");
      shared_ptr<CAppObject> tmpshared(new CAppObject());
      unique_ptr<CAppObject> ptr4(tmpshared.get());
      AssertPtr(ptr4,false);
      AssertError();
   }   
   
   {
      TestName("TEST: construct unique_ptr from weak_ptr");
      weak_ptr<CAppObject> tmpweak(new CAppObject());
      unique_ptr<CAppObject> ptr5(tmpweak);
      AssertPtr(ptr5,0,true,tmpweak.get().Id()); 
   }
   
   {
      TestName("TEST Error: construct unique_ptr from weak_ptr that was initalized from shared or unique ptr");
      shared_ptr<CAppObject> tmpshared1(new CAppObject);
      unique_ptr<CAppObject> tmpunique1(new CAppObject);
      weak_ptr<CAppObject> tmpweak1(tmpshared1);
      weak_ptr<CAppObject> tmpweak2(tmpunique1);
      unique_ptr<CAppObject> ptr6(tmpweak1);
      unique_ptr<CAppObject> ptr7(tmpweak2);
      AssertPtr(ptr6,false);
      AssertPtr(ptr7,false);
      AssertError();
   }
   
}

void TestWeakPtrConstructors()
{
   {
      TestName("TEST: construct weak_ptr from builtin pointer (lvalue)");
      CAppObject *builtin_ptr1 = new CAppObject();
      weak_ptr<CAppObject> ptr1(builtin_ptr1);   
      AssertPtr(ptr1,0,false,builtin_ptr1.Id());
      delete builtin_ptr1;
   }
   
   {
      TestName("TEST: construct weak_ptr from builtin object");
      CAppObject builtin_obj1;
      weak_ptr<CAppObject> ptr2(builtin_obj1);
      AssertPtr(ptr2,0,false,builtin_obj1.Id());
   }
   
   {
      TestName("TEST: construct weak_ptr from unique_ptr");
      unique_ptr<CAppObject> tmpunique(new CAppObject());
      weak_ptr<CAppObject> ptr3(tmpunique);
      AssertPtr(ptr3,0,true,tmpunique.get().Id());
   }
   
   {
      TestName("TEST: construct weak_ptr from shared_ptr");
      shared_ptr<CAppObject> tmpshared(new CAppObject());
      weak_ptr<CAppObject> ptr4(tmpshared);
      AssertPtr(ptr4,1,false,tmpshared.get().Id());
   }
   
   {
      TestName("TEST: construct weak_ptr from weak_ptr");
      weak_ptr<CAppObject> tmpweak(new CAppObject());
      weak_ptr<CAppObject> ptr5(tmpweak);
      AssertPtr(ptr5,0,false,tmpweak.get().Id());
      delete tmpweak.get();
   }
   
}

void TestSharedPtrAssign()
{
   {
      TestName("TEST: assign shared_ptr to empty shared_ptr");
      shared_ptr<CAppObject> ptr1;
      shared_ptr<CAppObject> tempshared1(new CAppObject());
      ptr1.assign(tempshared1);
      AssertPtr(ptr1,2,false,tempshared1.get().Id());
      AssertPtr(tempshared1,2,false,tempshared1.get().Id());
   }
   
   {   
      TestName("TEST: assign shared_ptr to already set shared_ptr");
      shared_ptr<CAppObject> tempshared1(new CAppObject());
      shared_ptr<CAppObject> tempshared2(new CAppObject());
      shared_ptr<CAppObject> ptr1(tempshared1);
      ptr1.assign(tempshared2);
      AssertPtr(ptr1,2,false,tempshared2.get().Id());
      AssertPtr(tempshared2,2,false,tempshared2.get().Id());
      AssertPtr(tempshared1,1,false,tempshared1.get().Id());
   }
   
   {
      TestName("TEST Error: assign unique_ptr to shared_ptr");
      unique_ptr<CAppObject> tempunique1(new CAppObject());
      CAppObject* tempobj1 = tempunique1.get();
      shared_ptr<CAppObject> ptr1(new CAppObject());
      shared_ptr<CAppObject> ptr3;
      ptr1.assign(tempunique1);
      AssertPtr(ptr1,false);
      ptr3.assign(tempunique1);
      AssertPtr(ptr3,false);
      AssertPtr(tempunique1,0,true,tempobj1.Id());
      AssertError();
   }
   
   {
      TestName("TEST: assign weak_ptr to shared_ptr");
      weak_ptr<CAppObject> tempweak1(new CAppObject());
      shared_ptr<CAppObject> ptr1(new CAppObject());
      shared_ptr<CAppObject> ptr4;
      ptr1.assign(tempweak1);
      AssertPtr(ptr1,1,false,tempweak1.get().Id());
      ptr4.assign(tempweak1);
      AssertPtr(ptr1,2,false,tempweak1.get().Id());
      AssertPtr(ptr4,2,false,tempweak1.get().Id());
   }
   
   {
      TestName("TEST: assign shared_ptr to shared_ptr of parent type");
      shared_ptr<CTestChildAppObject> tempshared3(new CTestChildAppObject());
      shared_ptr<CAppObject> ptr5;
      ptr5.assign(tempshared3);
      AssertPtr(ptr5,2,false,tempshared3.get().Id());
   }
   
   {
      TestName("TEST: assign shared_ptr to shared_ptr of parent type");
      shared_ptr<CAppObject> tempshared4(new CTestChildAppObject());
      shared_ptr<CTestChildAppObject> ptr6;
      ptr6.assign(tempshared4);
      AssertPtr(ptr6,2,false,tempshared4.get().Id());
   }
   
   {
      TestName("TEST: assign NULL shared_ptr to shared_ptr");
      shared_ptr<CAppObject> tempshared5(NULL);
      shared_ptr<CAppObject> ptr7(new CAppObject);
      CAppObject *tempobj2 = ptr7.get();
      ptr7.assign(tempshared5);
      AssertPtr(ptr7,false);
      AssertPtr(tempshared5,false);
      AssertObject(tempobj2,false);
   }
   
}


void TestUniquePtrAssign()
{
   {
      TestName("TEST Error: assign unique_ptr to empty unique_ptr of same type");
      unique_ptr<CAppObject> ptr1;
      unique_ptr<CAppObject> tempunique1(new CAppObject());
      CAppObject *tempobj1 = tempunique1.get();
      ptr1.assign(tempunique1);
      AssertPtr(ptr1,false);
      AssertPtr(tempunique1,0,true,tempobj1.Id());
      AssertError();
   }
   
   {
      TestName("TEST Error: assign unique_ptr to already set unique_ptr of the same type");
      unique_ptr<CAppObject> ptr1(new CAppObject);
      unique_ptr<CAppObject> tempunique2(new CAppObject());
      CAppObject *tempobj1 = tempunique2.get();
      ptr1.assign(tempunique2);
      AssertPtr(ptr1,false);
      AssertPtr(tempunique2,0,true,tempobj1.Id());
      AssertError();
   }
   
   {
      TestName("TEST Error: assign shared_ptr to unique_ptr");
      unique_ptr<CAppObject> ptr1(new CAppObject);
      shared_ptr<CAppObject> tempshared1(new CAppObject());
      CAppObject *tempobj1 = tempshared1.get();
      unique_ptr<CAppObject> ptr3;
      ptr1.assign(tempshared1);
      AssertPtr(ptr1,false);
      ptr3.assign(tempshared1);
      AssertPtr(ptr3,false);
      AssertPtr(tempshared1,1,false,tempobj1.Id());
      AssertError();
   }

   {
      TestName("TEST: assign weak_ptr to unique_ptr");
      weak_ptr<CAppObject> tempweak1(new CAppObject());
      unique_ptr<CAppObject> ptr4;
      ptr4.assign(tempweak1);
      AssertPtr(ptr4,0,true,tempweak1.get().Id());
   }
   
   {
      TestName("TEST: assign weak_ptr to unique_ptr already owning the same object");
      weak_ptr<CAppObject> tempweak2(new CAppObject());
      weak_ptr<CAppObject> tempweak3(tempweak2);
      unique_ptr<CAppObject> ptr5(tempweak2);
      ptr5.assign(tempweak3);
      AssertEqual(tempweak2.get().Id(),tempweak3.get().Id(),"id",false);
      AssertPtr(ptr5,0,true,tempweak2.get().Id());
   }
   
   {
      TestName("TEST: assign weak_ptr to unique_ptr of parent type");
      weak_ptr<CTestChildAppObject> tempweak4(new CTestChildAppObject());
      weak_ptr<CTestChildAppObject> tempweak5(new CTestChildAppObject());
      unique_ptr<CAppObject> ptr5(new CAppObject);
      unique_ptr<CAppObject> ptr6;
      ptr6.assign(tempweak4);
      ptr5.assign(tempweak5);
      AssertPtr(ptr6,0,true,tempweak4.get().Id());
      AssertPtr(ptr5,0,true,tempweak5.get().Id());
   }
   
   {
      TestName("TEST: assign shared_ptr to shared_ptr of child type");
      weak_ptr<CAppObject> tempweak6(new CTestChildAppObject());
      weak_ptr<CAppObject> tempweak7(new CTestChildAppObject());
      unique_ptr<CTestChildAppObject> ptr5(new CTestChildAppObject());
      unique_ptr<CTestChildAppObject> ptr7;
      ptr7.assign(tempweak6);
      ptr5.assign(tempweak7);
      AssertPtr(ptr7,0,true,tempweak6.get().Id());
      AssertPtr(ptr5,0,true,tempweak7.get().Id());
   }
   
   {
      TestName("TEST: assign NULL weak_ptr to unique_ptr");
      shared_ptr<CAppObject> tempweak8(NULL);
      unique_ptr<CAppObject> ptr8(new CAppObject);
      CAppObject *tempobj3 = ptr8.get();
      ptr8.assign(tempweak8);
      AssertPtr(ptr8,false);
      AssertPtr(tempweak8,false);
      AssertObject(tempobj3,false);
   }

}

void TestWeakPtrAssign()
{
   {
      TestName("TEST: assign shared_ptr to empty weak_ptr");
      shared_ptr<CAppObject> tempshared1(new CAppObject);
      weak_ptr<CAppObject> ptr1;
      ptr1.assign(tempshared1);
      AssertPtr(ptr1,1,false,tempshared1.get().Id());
   }
   
   {
      TestName("TEST: assign shared_ptr to not empty weak_ptr");
      shared_ptr<CAppObject> tempshared2(new CAppObject);
      CAppObject* obj = new CAppObject;
      CAppObject* obj1 = obj;
      weak_ptr<CAppObject> ptr1(obj);
      ptr1.assign(tempshared2);
      AssertPtr(ptr1,1,false,tempshared2.get().Id());
      AssertObject(obj,true,0,false,obj1.Id());
      delete obj;
   }
   
   {
      TestName("TEST: assign unique_ptr to weak_ptr");
      unique_ptr<CAppObject> tempunique1(new CAppObject);
      weak_ptr<CAppObject> ptr1;
      ptr1.assign(tempunique1);
      AssertPtr(ptr1,0,true,tempunique1.get().Id());
   }
   
   {
      TestName("TEST: assign weak_ptr to weak_ptr");
      unique_ptr<CAppObject> tempunique2(new CAppObject);
      weak_ptr<CAppObject> ptr2(tempunique2);
      weak_ptr<CAppObject> ptr3;
      ptr3.assign(ptr2);
      AssertPtr(ptr3,0,true,tempunique2.get().Id());
   }
}

void TestSharedPtrDestructors()
{
   {
      TestName("TEST: destructor: single unique_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         unique_ptr<CAppObject> ptr1(obj1);
      }
      AssertObject(obj1,false);
   }
   
   {
      TestName("TEST: destructor: single shared_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         shared_ptr<CAppObject> ptr1(obj1);
      }
      AssertObject(obj1,false);
   }
   
   {
      TestName("TEST: destructor: single weak_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         weak_ptr<CAppObject> ptr1(obj1);
      }
      AssertObject(obj1,true);
      delete obj1;
   }
   
   {
      TestName("TEST: destructor: two shared_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         shared_ptr<CAppObject> ptr1(obj1);
         {
            shared_ptr<CAppObject> ptr2(ptr1);
            AssertObject(obj1,true,2,false);
         }
         AssertObject(obj1,true,1,false);
      }
      AssertObject(obj1,false);
   }
   
   {
      TestName("TEST: destructor: unique_ptr and weak_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         unique_ptr<CAppObject> ptr1(obj1);
         {
            weak_ptr<CAppObject> ptr2(ptr1);
            AssertObject(obj1,true,0,true);
         }
         AssertObject(obj1,true,0,true);
      }      
      AssertObject(obj1,false);
   }
   
   {
      TestName("TEST: destructor: shared_ptr and weak_ptr");
      CAppObject *obj1 = new CAppObject();
      {
         shared_ptr<CAppObject> ptr1(obj1);
         {
            weak_ptr<CAppObject> ptr2(ptr1);
            AssertObject(obj1,true,1,false);
         }
         AssertObject(obj1,true,1,false);
      }      
      AssertObject(obj1,false);
   }
   
}

void TestReset()
{
   {
      TestName("TEST: reset: shared_ptr from new builtin pointer");
      CAppObject *obj = new CAppObject();
      CAppObject *obj1 = new CAppObject();
      shared_ptr<CAppObject> ptr1;
      shared_ptr<CAppObject> ptr2(obj1);
      ptr1.reset(obj);
      AssertPtr(ptr1,1,false,obj.Id());
      ptr2.reset(obj);
      AssertPtr(ptr2,2,false,obj.Id());
      AssertObject(obj1,false);
   }
   
   {
      TestName("TEST: reset: unique_ptr from new builtin pointer");
      CAppObject *obj = new CAppObject();
      CAppObject *obj1 = new CAppObject();
      CAppObject *obj2 = new CAppObject();
      unique_ptr<CAppObject> ptr1;
      unique_ptr<CAppObject> ptr2(obj1);
      ptr1.reset(obj);
      AssertPtr(ptr1,0,true,obj.Id());
      ptr2.reset(obj2);
      AssertPtr(ptr2,0,true,obj2.Id());
      AssertObject(obj1,false);
   }

   {
      TestName("TEST: reset: weak_ptr from new builtin pointer");
      CAppObject *obj = new CAppObject();
      CAppObject *obj1 = new CAppObject();
      weak_ptr<CAppObject> ptr1;
      weak_ptr<CAppObject> ptr2(obj1);
      ptr1.reset(obj);
      AssertPtr(ptr1,0,false,obj.Id());
      ptr2.reset(obj);
      AssertPtr(ptr2,0,false,obj.Id());
      delete obj;
      delete obj1;
   }

   {
      TestName("TEST Warning: reset: shared_ptr from managed object");
      CAppObject obj;
      shared_ptr<CAppObject> ptr1;
      ptr1.reset(GetPointer(obj));
      AssertPtr(ptr1,1,false,obj.Id());
      ptr1.detach();
      AssertWarning();
   }

   {
      TestName("TEST Warning: reset: unique_ptr from managed object");
      CAppObject obj;
      unique_ptr<CAppObject> ptr1;
      ptr1.reset(GetPointer(obj));
      AssertPtr(ptr1,0,true,obj.Id());
      ptr1.detach();
      AssertWarning();
   }

   {
      TestName("TEST: reset: weak_ptr from managed object");
      CAppObject obj;
      weak_ptr<CAppObject> ptr1;
      ptr1.reset(GetPointer(obj));
      AssertPtr(ptr1,0,false,obj.Id());
   }
   
   {
      TestName("TEST Error: reset: shared_ptr from object of unique_ptr");
      CAppObject *obj = new CAppObject();
      unique_ptr<CAppObject> tempunique(obj);
      shared_ptr<CAppObject> ptr1(new CAppObject);
      ptr1.reset(obj);
      AssertPtr(ptr1,false);  
      AssertError();
   }

  {
      TestName("TEST Error: reset: unique_ptr from object of unique_ptr");
      CAppObject *obj = new CAppObject();
      unique_ptr<CAppObject> tempunique(obj);
      unique_ptr<CAppObject> ptr1(new CAppObject);
      ptr1.reset(obj);
      AssertPtr(ptr1,false);  
      AssertError();
   }

  {
      TestName("TEST Error: reset: unique_ptr from object of shared_ptr");
      CAppObject *obj = new CAppObject();
      shared_ptr<CAppObject> tempunique(obj);
      unique_ptr<CAppObject> ptr1(new CAppObject);
      ptr1.reset(obj);
      AssertPtr(ptr1,false);  
      AssertError();
   }

   {
      TestName("TEST: reset: unique_ptr from same object");
      CAppObject *obj = new CAppObject();
      unique_ptr<CAppObject> ptr1(obj);
      ptr1.reset(obj);
      AssertPtr(ptr1,0,true,obj.Id());           
   }
   
   {
      TestName("TEST: reset: shared_ptr from same object");
      CAppObject *obj = new CAppObject();
      shared_ptr<CAppObject> ptr1(obj);
      ptr1.reset(obj);
      AssertPtr(ptr1,1,false,obj.Id());
   }

   {
      TestName("TEST: reset: shared_ptr from NULL");
      CAppObject *obj = NULL;
      shared_ptr<CAppObject> ptr1(new CAppObject);
      ptr1.reset(obj);
      AssertPtr(ptr1,false);
   }

  {
      TestName("TEST: reset: unique_ptr from NULL");
      CAppObject *obj = NULL;
      unique_ptr<CAppObject> ptr1(new CAppObject);
      ptr1.reset(obj);
      AssertPtr(ptr1,false);
   }

  {
      TestName("TEST: reset: weak_ptr from NULL");
      CAppObject *obj = NULL;
      weak_ptr<CAppObject> ptr1;
      ptr1.reset(obj);
      AssertPtr(ptr1,false);
   }

}

void TestDetach()
{
   {
      TestName("TEST: detach shared_ptr");
      CAppObject *obj1 = new CAppObject;
      shared_ptr<CAppObject> ptr1(obj1);
      CAppObject *obj2 = ptr1.detach();
      AssertPtr(ptr1,false);
      AssertObject(obj2,true,0,false,obj1.Id());
      CAppObject *obj3 = ptr1.detach();
      AssertObjectNULL(obj3);
      delete obj1;
   }

   {
      TestName("TEST: detach unique_ptr");
      CAppObject *obj1 = new CAppObject;
      unique_ptr<CAppObject> ptr1(obj1);
      CAppObject *obj2 = ptr1.detach();
      AssertPtr(ptr1,false);
      AssertObject(obj2,true,0,false,obj1.Id());
      CAppObject *obj3 = ptr1.detach();
      AssertObjectNULL(obj3);
      delete obj1;
   }

   {
      TestName("TEST: detach weak_ptr");
      CAppObject *obj1 = new CAppObject;
      weak_ptr<CAppObject> ptr1(obj1);
      CAppObject *obj2 = ptr1.detach();
      AssertPtr(ptr1,false);
      AssertObject(obj2,true,0,false,obj1.Id());
      CAppObject *obj3 = ptr1.detach();
      AssertObjectNULL(obj3);
      delete obj1;
   }

}

void TestMakeFunctions()
{
   {
      TestName("TEST: shared_ptr::make_shared");
      {
         TestName("TEST: shared_ptr::make_shared from dynamic object");
         AssertPtr(shared_ptr<CAppObject>::make_shared(new CAppObject),1,false,0);
         // for some reason this is giving compilation error:
         // shared_ptr<CAppObject> ptr1(shared_ptr<CAppObject>::make_shared(new CAppObject));
         // but nevermind, this is equivalent:
         shared_ptr<CAppObject> ptr1 = shared_ptr<CAppObject>::make_shared(new CAppObject);
         AssertPtr(ptr1,2,false,0);
         weak_ptr<CAppObject> ptr2 = shared_ptr<CAppObject>::make_shared(new CAppObject);
         AssertPtr(ptr2,1,false,0);
      }

      {
         TestName("TEST: shared_ptr::make_shared from shared_ptr");
         {
            // same type
            shared_ptr<CAppObject> ptr1(new CAppObject);
            shared_ptr<CAppObject> ptr2 = shared_ptr<CAppObject>::make_shared(ptr1);
            AssertPtr(ptr2,3,false,ptr1.get().Id());
         }
         {
            // from child type
            shared_ptr<CTestChildAppObject> ptr1(new CTestChildAppObject);
            shared_ptr<CAppObject> ptr2 = shared_ptr<CAppObject>::make_shared(ptr1);
            AssertPtr(ptr2,3,false,ptr1.get().Id());
         }
         {
            // from parent type (but compatible object)
            shared_ptr<CAppObject> ptr1(new CTestChildAppObject);
            shared_ptr<CTestChildAppObject> ptr2 = shared_ptr<CTestChildAppObject>::make_shared(ptr1);
            AssertPtr(ptr2,3,false,ptr1.get().Id());
         }
         {
            // Be careful to avoid this case, giving hardly trackable runtime error:
            /*
            shared_ptr<CAppObject> ptr1(new CAppObject);
            shared_ptr<CTestChildAppObject> ptr2 = shared_ptr<CTestChildAppObject>::make_shared(ptr1);
            AssertPtr(ptr2,3,false,ptr1.get().Id());
            */
         }
      }
      
      {
         TestName("TEST: shared_ptr::make_shared from weak_ptr");
         {
            weak_ptr<CAppObject> ptr1(new CAppObject);
            shared_ptr<CAppObject> ptr2 = shared_ptr<CAppObject>::make_shared(ptr1);
            AssertPtr(ptr2,2,false,ptr1.get().Id());
         }
   
         {
            shared_ptr<CAppObject> ptr1(new CAppObject);
            weak_ptr<CAppObject> ptr2(ptr1);
            shared_ptr<CAppObject> ptr3 = shared_ptr<CAppObject>::make_shared(ptr1);
            AssertPtr(ptr3,3,false,ptr1.get().Id());
         }
      }
      
      {
         TestName("TEST: empty shared_ptr::make_shared");
         shared_ptr<CAppObject> ptr1 = shared_ptr<CAppObject>::make_shared();
         AssertPtr(ptr1,false);
      }

   }
   
   {
      TestName("TEST: unique_ptr::make_unique");
      {
         TestName("TEST: unique_ptr::make_unique from dynamic object");
         AssertPtr(unique_ptr<CAppObject>::make_unique(new CAppObject),0,true,0);
      }
      {
         TestName("TEST: unique_ptr::make_unique from weak_ptr");
         weak_ptr<CAppObject> ptr1(new CAppObject);
         AssertPtr(unique_ptr<CAppObject>::make_unique(ptr1),0,true,0);
      }
      {
         TestName("TEST: empty unique_ptr::make_unique");
         AssertPtr(unique_ptr<CAppObject>::make_unique(),false);
      }
   }
   
   {
      TestName("TEST: weak_ptr::make_weak");
      {
         TestName("TEST: weak_ptr::make_weak from dynamic object");
         CAppObject *obj = new CAppObject;
         AssertPtr(weak_ptr<CAppObject>::make_weak(obj),0,false,obj.Id());
         delete obj;
      }
      {
         TestName("TEST: weak_ptr::make_weak from managed object");
         CAppObject obj;
         AssertPtr(weak_ptr<CAppObject>::make_weak(obj),0,false,obj.Id());
      }
      {
         TestName("TEST: weak_ptr::make_weak from shared_ptr");
         shared_ptr<CAppObject> ptr1(new CAppObject);
         AssertPtr(weak_ptr<CAppObject>::make_weak(ptr1),1,false,ptr1.get().Id());
      }
      {
         TestName("TEST: weak_ptr::make_weak from unique_ptr");
         unique_ptr<CAppObject> ptr1(new CAppObject);
         AssertPtr(weak_ptr<CAppObject>::make_weak(ptr1),0,true,ptr1.get().Id());
      }
      {
         TestName("TEST: weak_ptr::make_weak from weak_ptr");
         weak_ptr<CAppObject> ptr1(new CAppObject);
         AssertPtr(weak_ptr<CAppObject>::make_weak(ptr1),0,false,ptr1.get().Id());
         delete ptr1.detach();
      }
   }
}

void TestFunctions()
{
   CAppObject *tempobj;

   {
      TestName("TEST: function accepting base_ptr, receiving shared_ptr");
      CAppObject *obj = new CAppObject;
      tempobj = obj;
      FunctionAcceptingBase(shared_ptr<CAppObject>::make_shared(obj),true,1,false,obj.Id());
      //Equivalent:
      shared_ptr<CAppObject> ptr(obj);
      FunctionAcceptingBase(ptr,true,2,false,obj.Id());
   }
   AssertObject(tempobj,false);

   {
      TestName("TEST: function accepting base_ptr, receiving weak_ptr");
      CAppObject *obj = new CAppObject;
      tempobj = obj;
      FunctionAcceptingBase(weak_ptr<CAppObject>::make_weak(obj),true,0,false,obj.Id());
   }
   AssertObject(tempobj,true);
   delete tempobj;

   {
      TestName("TEST: function accepting base_ptr, receiving unique_ptr");
      CAppObject *obj = new CAppObject;
      tempobj = obj;
      FunctionAcceptingBase(unique_ptr<CAppObject>::make_unique(obj),true,0,true,obj.Id());
   }
   AssertObject(tempobj,false);
   
   {
      TestName("TEST: function returning weak_ptr");
      weak_ptr<CAppObject> ptr = FunctionReturningWeakPointer(shared_ptr<CAppObject>::make_shared(new CAppObject),1);
      
      AssertPtr(ptr,1,false,0);  
      
      //Equivalent:
      AssertPtr(FunctionReturningWeakPointer(shared_ptr<CAppObject>::make_shared(new CAppObject),1),1,false,0);
      
      AssertPtr(FunctionReturningWeakPointer(1),false);
      
      // You can initalize shared_ptr or unique_ptr using the returned weak_ptr
      shared_ptr<CAppObject> ptr2(FunctionReturningWeakPointer(2));
      AssertPtr(ptr2,true,1,false);

      unique_ptr<CAppObject> ptr3(FunctionReturningWeakPointer(2));
      AssertPtr(ptr3,true,0,true);
      
   }
   
   {
   
      TestName("TEST: function returning shared_ptr");
      // It has refcount=2 because there are 2 temporary shared_ptr object, one returned by make_shared(), and one returned by FunctionReturningSharedPointer().
      AssertPtr(FunctionReturningSharedPointer(shared_ptr<CAppObject>::make_shared(new CAppObject),1),2,false,0);
      AssertPtr(FunctionReturningSharedPointer(1),1,false,0);
      AssertPtr(FunctionReturningSharedPointer(2),false);
      
      shared_ptr<CAppObject> ptr1(FunctionReturningSharedPointer(shared_ptr<CAppObject>::make_shared(new CAppObject),1));
      AssertPtr(ptr1,3,false,0);

      shared_ptr<CAppObject> ptr2(FunctionReturningSharedPointer(1));
      AssertPtr(ptr2,2,false,0);

      shared_ptr<CAppObject> ptr3(FunctionReturningSharedPointer(2));
      AssertPtr(ptr3,false);
      
      shared_ptr<CAppObject> ptr4(FunctionReturningSharedPointer(shared_ptr<CAppObject>::make_shared(new CAppObject)));
      AssertPtr(ptr4,3,false,0);
      
      shared_ptr<CAppObject> ptr5(FunctionReturningSharedPointer(weak_ptr<CAppObject>::make_weak(shared_ptr<CAppObject>::make_shared(new CAppObject))));
      AssertPtr(ptr5,3,false,0);
      
      // returning NULL
      weak_ptr<CAppObject> tempweak(new CAppObject);
      shared_ptr<CAppObject> ptr6(FunctionReturningSharedPointer(tempweak));
      AssertPtr(ptr6,false);
      delete tempweak.detach();
      
      shared_ptr<CAppObject> ptr7(FunctionReturningSharedPointer(unique_ptr<CAppObject>::make_unique(new CAppObject)));
      AssertPtr(ptr7,false);
      
   }
   
}

// Best Practices:
// Generally use base_ptr as parameter if you want to use the object only during the function call
void FunctionAcceptingBase(base_ptr<CAppObject> &ptr, const bool isset, const int ref_count, const bool owned, const int id)
{
   // function can use base_ptr regardless of it's pointer type
   AssertPtr(ptr,true,ref_count,owned,id);
}

// Compilation Error: Cannot construct base_ptr directly
/*
base_ptr<CAppObject> FunctionReturningBase(base_ptr<CAppObject> &ptr)
{
   return ptr;
}
*/

// In special situations you can return pointer to a base_ptr, it doesn't need construct
base_ptr<CAppObject> *FunctionReturningPointerToBase(base_ptr<CAppObject> &ptr)
{
   return GetPointer(ptr);
}

// You can return weak pointer that can be initalized from any type of pointers
// The caller can initalize shared_ptr or unique_ptr from weak_ptr,
// but that is the caller's responsibility to check if that operation is valid
weak_ptr<CAppObject> FunctionReturningWeakPointer(base_ptr<CAppObject> &ptr, const int id)
{
   switch(id) {
      case 1: return ptr;
      // Same result, just little longer
      case 2: return ptr.get();
   }
   return NULL;
}

weak_ptr<CAppObject> FunctionReturningWeakPointer(const int id)
{
   switch(id) {
      case 1: return NULL;
      // this pointer will not be deleted automatically
      case 2: return new CAppObject;
      //
      case 3:
         // This is mistake, the pointer will be deleted at the end of call
         // It will do the following steps:
         // 1. Create temporary object returned by make_shared
         // 2. Use temporary object as parameter of constructor of weak_ptr in order to create the returned weak_ptr object
         // 3. delete the temporary object (as it was shared_ptr, it will delete the pointed object)
         // 4. The created object in step 2 is returned to the caller
         return shared_ptr<CAppObject>::make_shared(new CAppObject);
         // equivalent to:
      case 4:
      {
         shared_ptr<CAppObject> ptr(new CAppObject);
         return ptr;
      }
   }
   return NULL;
}

// Best Practices:
// If you are receiving shared_ptr you should return it as shared_ptr to make sure the caller can use it further
shared_ptr<CAppObject> FunctionReturningSharedPointer(shared_ptr<CAppObject> &ptr, const int id)
{
   switch(id) {
      case 1: return ptr;
      case 2: return ptr.get();
   }
   return NULL;
}

// Best Practices:
// If you are creating new object within function, it's better to return shared_ptr to make sure it's deleted even if the caller doesn't use the result at all
shared_ptr<CAppObject> FunctionReturningSharedPointer(const int id)
{
   switch(id) {
      // You can return object directly
      case 1: return new CAppObject();
      // You can return NULL pointer
      case 2: return NULL;
   }
   return NULL;
}

shared_ptr<CAppObject> FunctionReturningSharedPointer(base_ptr<CAppObject> &ptr)
{
   // you can force initalization of any ptr using get(), but it's wise to check whether it has the properties you need
   // this condition allows initalization from get() if the parameter is a shared_ptr, or a weak_ptr that was earlier initalized from a shared_ptr
   if (ptr.ptrtype() == ptrShared || (ptr.ptrtype() == ptrWeak && !ptr.owned() && ptr.refcount() > 0)) return ptr.get();
   return NULL;
}


virtual bool OnBegin()
{
   // Test shared pointer
   _DisableReportingError = true;
   _DisableReportingWarning = true;
   
   TestSharedPtrConstructors();
   TestUniquePtrConstructors();
   TestWeakPtrConstructors();

   TestSharedPtrDestructors();
   
   TestSharedPtrAssign();
   TestUniquePtrAssign();
   TestWeakPtrAssign();
   
   TestReset();   
   
   TestDetach();
   
   TestMakeFunctions();
   
   TestFunctions();
   
   _DisableReportingError = false;
   _DisableReportingWarning = false;

   return false;
}
   
};
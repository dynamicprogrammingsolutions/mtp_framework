//
class CAttachedOrder : public COrderBase
{
public:
   virtual int Type() const { return classMT5AttachedOrder; }
public:
   string name;
   bool filling_updated;
   static CAttachedOrder* Null() { return(new CAttachedOrder()); }
   
   virtual bool Save(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      if (!file.WriteString(name)) return file.Error("name",__FUNCTION__);
      if (!file.WriteBool(filling_updated)) return file.Error("filling_updated",__FUNCTION__);
      if (!COrderBase::Save(handle)) return file.Error("COrderBase",__FUNCTION__);
      return(true);
   }
   
   virtual bool Load(const int handle)
   {
      MTPFileBin file;
      file.Handle(handle);            
      if (file.Invalid()) return false;
      if (!file.ReadString(name)) return file.Error("name",__FUNCTION__);
      if (!file.ReadBool(filling_updated)) return file.Error("filling_updated",__FUNCTION__);
      if (!COrderBase::Load(handle)) return file.Error("COrderBase",__FUNCTION__);
      return(true);
   }
   
};

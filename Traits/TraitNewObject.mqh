#define TraitNewObject virtual bool callback(const int __id, CObject*& obj) { obj = NewObject(); return true; } virtual CObject* NewObject()
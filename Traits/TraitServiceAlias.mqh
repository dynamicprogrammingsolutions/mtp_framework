//
#define TraitServiceAlias(__interface__,__service__,__alias__) __interface__ __alias__() { return App().__service__; }
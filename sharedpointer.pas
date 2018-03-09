unit SharedPointer;

interface

uses
  System.Generics.Collections;

type
  TDeallocator = reference to procedure(AObj: TObject);

  TShared<T: class> = record
  private
    FFreeTheValue: IInterface;
  public
    constructor Create(AValue: T);
    procedure Assign(AValue: T);
    procedure SetDeallocator(ADealloc: TDeallocator);

    function Temporary: T;

    function Cast<TT: class>: TShared<TT>;

    { Release the object from the TShared<T> convention.  The object
      will no-longer be Free'ed using TShared<T> and should be managed manually. }
    function Release: T;
  end;


  TFreeTheValue = class(TInterfacedObject)
  public
    FObjectToFree: TObject;
    FCustomDeallocator: TDeallocator;
    constructor Create(AObjToFree: TObject);
    destructor Destroy; override;
  end;

  TSharedList<T: class> = record
  private
    FFreeTheValue: IInterface;
    function List: TList<TShared<T>>;
    procedure Initialize();
    function GetItem(I: Integer): T;
    function GetSharedItem(I: Integer): TShared<T>;
  public
    function Count: Integer;
    property Items[I: Integer]: T read GetItem;
    property SharedItems[I: Integer]: TShared<T> read GetSharedItem; default;
    procedure Add(AObject: TShared<T>);
    procedure Clear;
  end;

implementation

uses
  System.SysUtils;

function TShared<T>.Temporary: T;
begin
  Result := nil;
  if (FFreeTheValue <> nil) and ((FFreeTheValue as TFreeTheValue).FObjectToFree <> nil) then
    Result := (FFreeTheValue as TFreeTheValue).FObjectToFree as T;
end;

constructor TFreeTheValue.Create(AObjToFree: TObject);
begin
  FObjectToFree := AObjToFree;
end;

destructor TFreeTheValue.Destroy;
begin
  if Assigned(FObjectToFree) then
  begin
    if Assigned(FCustomDeallocator) then
    begin
      FCustomDeallocator(FObjectToFree);
      FObjectToFree := nil;
      FCustomDeallocator := nil;
    end
    else
    begin
      FreeAndNil(FObjectToFree);
    end;
  end;
end;

function TShared<T>.Cast<TT>: TShared<TT>;
begin
  Result := TShared<TT>.Create(nil);
  Result.FFreeTheValue := FFreeTheValue;
end;

constructor TShared<T>.Create(AValue: T);
begin
  Assign(AValue);
end;

procedure TShared<T>.Assign(AValue: T);
begin
  FFreeTheValue := TFreeTheValue.Create(AValue);
end;

function TShared<T>.Release: T;
begin
  Result := Temporary;
  (FFreeTheValue as TFreeTheValue).FObjectToFree := nil;
end;

procedure TShared<T>.SetDeallocator(ADealloc: TDeallocator);
begin
  (FFreeTheValue as TFreeTheValue).FCustomDeallocator := ADealloc;
end;

{ TSharedList<T> }

procedure TSharedList<T>.Add(AObject: TShared<T>);
begin
  Initialize;
  List.Add(AObject);
end;

procedure TSharedList<T>.Clear;
begin
  FFreeTheValue := nil;
end;

function TSharedList<T>.Count: Integer;
begin
  Initialize;
  Result := List.Count;
end;

function TSharedList<T>.GetSharedItem(I: Integer): TShared<T>;
var
  Temp: TList<TShared<T>>;
begin
  Temp := List;
  if Assigned(Temp) then
    Result := Temp.Items[I];
end;

procedure TSharedList<T>.Initialize;
begin
  if (FFreeTheValue = nil) then
  begin
    FFreeTheValue := TFreeTheValue.Create(TList<TShared<T>>.Create);
  end;
end;

function TSharedList<T>.GetItem(I: Integer): T;
var
  Temp: TShared<T>;
begin
  Temp := GetSharedItem(I);
  Result := Temp.Temporary;
end;

function TSharedList<T>.List: TList<TShared<T>>;
begin
  Initialize;
  Result := (FFreeTheValue as TFreeTheValue).FObjectToFree as TList<TShared<T>>;
end;

end.

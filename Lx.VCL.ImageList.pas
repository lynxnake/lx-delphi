unit Lx.VCL.ImageList;

interface

uses
  System.Classes,
  VCL.Controls;

type
  /// <summary>Fixes TimageList.Bitmap constantly changing</summary>
  /// <remarks> Might be useful if DFM is stored in version control system </remarks>
  TLXImageList = class(TImageList)
  protected
    procedure WriteData(Stream: TStream); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Lx', [TLXImageList]);
end;

{ TKBImageList }

procedure TLXImageList.WriteData(Stream: TStream);
const
  ConstantByte: Byte = 55;
  ErrorOffset = 8;
var
  Pos1, pomPos2: Int64;
begin
  Pos1 := Stream.Position;
  inherited;
  pomPos2 := Stream.Position;
  Stream.Position := Pos1 + ErrorOffset;
  Stream.Write(ConstantByte, SizeOf(ConstantByte));
  Stream.Position := pomPos2;
end;

end.

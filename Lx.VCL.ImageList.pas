unit Lx.VCL.ImageList;

interface
uses
  System.Classes,
  VCL.Controls;

type
  {$MESSAGE FATAL 'Does not work'}
  /// <summary>Fixes TimageList.Bitmap constantly changing</summary>
  /// <remarks> Might be useful if DFM is stored in version control system </remarks>
  TLXImageList = class(TImageList)
  protected
    procedure WriteData(Stream: TStream); override;
    procedure ReadData(Stream: TStream); override;
  end;

procedure Register;

implementation

uses
  System.SysUtils,
  System.Types,
  System.Win.ComObj,
  Winapi.ActiveX,
  Winapi.CommCtrl,
  Winapi.Windows;

procedure Register;
begin
  RegisterComponents('Lx', [TLXImageList]);
end;

{ TKBImageList }

type
  TImageListWriteExProc = function(ImageList: HIMAGELIST; Flags: DWORD;
    Stream: IStream): HRESULT; {$IFNDEF CLR}stdcall;{$ENDIF}

{ Raise EOleSysError exception from an error code }

procedure OleError(ErrorCode: HResult);
begin
  raise EOleSysError.Create('', ErrorCode, 0);
end;

{ Raise EOleSysError exception if result code indicates an error }

procedure OleCheck(Result: HResult);
begin
  if not Succeeded(Result) then OleError(Result);
end;

procedure TLXImageList.ReadData(Stream: TStream);
var
  LAdapter: TStreamAdapter;
  riid: TGUID;
  IL: Pointer;
  ppv: Pointer;
  Res: HRESULT;
begin
  LAdapter := TStreamAdapter.Create(Stream);
  try
    riid := GUID_NULL;
    IL := nil;
    ppv := @IL;
    Res := ImageList_ReadEx(ILP_NORMAL, LAdapter, riid, ppv);
    OleCheck(Res);
  finally
    LAdapter.Free;
  end;
end;

procedure TLXImageList.WriteData(Stream: TStream);
var
  SA: TStreamAdapter;
  ComCtrlHandle: THandle;
  ImageListWriteExProc: TImageListWriteExProc;
const
  ILP_DOWNLEVEL = 1;
begin
  ComCtrlHandle := GetModuleHandle(comctl32);
  if ComCtrlHandle <> 0 then
  begin
    ImageListWriteExProc := GetProcAddress(ComCtrlHandle, 'ImageList_WriteEx');

    SA := TStreamAdapter.Create(Stream);
    try
      { See if we should use the new API for writing image lists in the old format. }
      if Assigned(ImageListWriteExProc) then
      begin
        if ImageListWriteExProc(Handle, ILP_DOWNLEVEL, SA) <> S_OK then
          raise EWriteError.Create('Res@SImageWriteFail')
      end
      else if not ImageList_Write(Handle, SA) then
          raise EWriteError.Create('Res@SImageWriteFail');
    finally
      SA.Free;
    end;
  end;
end;

end.

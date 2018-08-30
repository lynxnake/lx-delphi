# lx-delphi
Various own fixes for Delphi

- `Lx.Vcl.ImageList.pas` - is not working. problem seem to be in `comctl32.dll` of file version `5.82.16299.302`, `product version 10.0.16299.402` - it reports `E_NOTIMPL` on try to call `ImageList_ReadEx` with `dwFlags` = `ILP_NORMAL`
 Useful links: https://quality.embarcadero.com/browse/RSP-13666, https://stackoverflow.com/q/10744505/198852
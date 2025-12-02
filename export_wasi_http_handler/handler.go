package export_wasi_http_handler

import (
	. "wit_component/wasi_http_types"
	. "wit_component/wit_types"
)

// Handle the specified `Request`, returning a `Response`
func Handle(request *Request) Result[*Response, ErrorCode] {
	tx, rx := MakeStreamU8()

	go func() {
		defer tx.Drop()
		tx.Write([]uint8("hello, world!"))
	}()

	headers := FieldsFromList([]Tuple2[string, []uint8]{
		Tuple2[string, []uint8]{"content-type", []uint8("text/plain")},
	})

	response, send := ResponseNew(
		headers.Ok(),
		MakeOptionSome(rx),
		trailersFuture(),
	)
	send.Drop()

	return MakeResultOk[*Response, ErrorCode](response)
}

func trailersFuture() *FutureReader[Result[Option[*Fields], ErrorCode]] {
	tx, rx := MakeFutureResultOptionWasiHttpTypesFieldsWasiHttpTypesErrorCode()
	go tx.Write(MakeResultOk[Option[*Fields], ErrorCode](MakeOptionNone[*Fields]()))
	return rx
}

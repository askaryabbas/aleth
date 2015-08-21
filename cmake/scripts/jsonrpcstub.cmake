# generates JSONRPC Stub Server && Client
#
# this script expects
# ETH_SOURCE_DIR - main CMAKE_SOURCE_DIR
# ETH_SPEC_PATH
# ETH_SERVER_DIR
# ETH_CLIENT_DIR
# ETH_SERVER_NAME
# ETH_CLIENT_NAME
# ETH_JSON_RPC_STUB
#
# example usage:
# cmake -DETH_SPEC_PATH=spec.json -DETH_SERVER_DIR=libweb3jsonrpc -DETH_CLIENT_DIR=test
# -DETH_SERVER_NAME=AbstractWebThreeStubServer -DETH_CLIENT_NAME=WebThreeStubClient -DETH_JSON_RPC_STUB=/usr/local/bin/jsonrpcstub

# setup names, and allow different filename from classname for namespaced classes.
# For an example call look at libethereum/CMakeLists.txt for eth::dev::Sentinel
if (ETH_SERVER_FILENAME)
	set(SERVER_TMPFILE "${ETH_SERVER_DIR}/${ETH_SERVER_FILENAME}.h.tmp")
	set(SERVER_OUTFILE "${ETH_SERVER_DIR}/${ETH_SERVER_FILENAME}.h")
else ()
	set(SERVER_TMPFILE "${ETH_SERVER_DIR}/${ETH_SERVER_NAME}.h.tmp")
	set(SERVER_OUTFILE "${ETH_SERVER_DIR}/${ETH_SERVER_NAME}.h")
endif()
if (ETH_CLIENT_FILENAME)
	set(CLIENT_TMPFILE "${ETH_CLIENT_DIR}/${ETH_CLIENT_FILENAME}.h.tmp")
	set(CLIENT_OUTFILE "${ETH_CLIENT_DIR}/${ETH_CLIENT_FILENAME}.h")
else ()
	set(CLIENT_TMPFILE "${ETH_CLIENT_DIR}/${ETH_CLIENT_NAME}.h.tmp")
	set(CLIENT_OUTFILE "${ETH_CLIENT_DIR}/${ETH_CLIENT_NAME}.h")
endif ()

# create tmp files
if (NOT ETH_SERVER_DIR)
	execute_process(
		COMMAND ${ETH_JSON_RPC_STUB} ${ETH_SPEC_PATH}
			--cpp-client=${ETH_CLIENT_NAME} --cpp-client-file=${CLIENT_TMPFILE}
			OUTPUT_VARIABLE ERR ERROR_QUIET
			)
else ()
	execute_process(
		COMMAND ${ETH_JSON_RPC_STUB} ${ETH_SPEC_PATH}
			--cpp-server=${ETH_SERVER_NAME} --cpp-server-file=${SERVER_TMPFILE}
			--cpp-client=${ETH_CLIENT_NAME} --cpp-client-file=${CLIENT_TMPFILE}
			OUTPUT_VARIABLE ERR ERROR_QUIET
	)
endif()

# don't throw fatal error on jsonrpcstub error, someone might have old version of jsonrpcstub,
# he does not need to upgrade it if he is not working on JSON RPC
# show him warning instead
if (ERR)
	message(WARNING "Your version of jsonrcpstub tool is not supported. Please upgrade it.")
	message(WARNING "${ERR}")
else()
  include("${ETH_SOURCE_DIR}/cmake/EthUtils.cmake")
  if (ETH_SERVER_DIR)
	replace_if_different("${SERVER_TMPFILE}" "${SERVER_OUTFILE}")
endif()
	replace_if_different("${CLIENT_TMPFILE}" "${CLIENT_OUTFILE}")
endif()

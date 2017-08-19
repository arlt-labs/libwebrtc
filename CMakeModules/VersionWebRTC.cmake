include(LibWebRTCExecute)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} clone ${LIBWEBRTC_WEBRTC_GIT} ${CMAKE_BINARY_DIR}/webrtc/src
    OUTPUT_VARIABLE _WEBRTC_CLONE
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    STAMPFILE webrtc-version-clone
    STATUS "Cloning webrtc"
    ERROR "Unable to clone webrtc"
)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} config remote.origin.fetch +refs/branch-heads/*:refs/remotes/branch-heads/* ^\\+refs/branch-heads/\\*:.*$
    OUTPUT_VARIABLE _WEBRTC_CONFIG_FETCH
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
    STAMPFILE webrtc-version-config-fetch
    STATUS "Setting up branch-heads refspecs"
    ERROR "Unable to add branch-heads refspec to the git config"
)

libwebrtc_execute(
    COMMAND ${GIT_EXECUTABLE} fetch origin
    OUTPUT_VARIABLE _WEBRTC_FETCH
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
    STAMPFILE webrtc-version-fetch-branch-heads
    STATUS "Fetching webrtc"
    ERROR "Unable to fetch webrtc"
)

if (WEBRTC_REVISION)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} checkout ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_CHECKOUT
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
      STAMPFILE
      STATUS "Checking out webrtc to commit ${WEBRTC_REVISION}"
      ERROR "Unable to checkout webrtc to commit ${WEBRTC_REVISION}"
  )
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} branch -r --contains ${WEBRTC_REVISION}
      OUTPUT_VARIABLE _WEBRTC_BRANCHES
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
      STAMPFILE
      STATUS "Get branches for ${WEBRTC_REVISION}"
      ERROR "Unable to get branches for ${WEBRTC_REVISION}"
  )
  set(LIBWEBRTC_WEBRTC_REVISION "${WEBRTC_REVISION}")
  string(REGEX REPLACE "^[ ]*([a-zA-Z0-9/_-]+).*" "\\1" _WEBRTC_BRANCHES "${_WEBRTC_BRANCHES}")
  get_filename_component(LIBWEBRTC_WEBRTC_BRANCH_NAME "${_WEBRTC_BRANCHES}" NAME)
elseif (WEBRTC_BRANCH_HEAD)
  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} fetch origin ${WEBRTC_BRANCH_HEAD}
      OUTPUT_VARIABLE _WEBRTC_FETCH
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
      STAMPFILE
      STATUS "Fetching ${WEBRTC_BRANCH_HEAD}"
      ERROR "Unable to fetch ${WEBRTC_BRANCH_HEAD}"
  )

  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} checkout FETCH_HEAD
      OUTPUT_VARIABLE _WEBRTC_CHECKOUT
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
      STAMPFILE
      STATUS "Checking out ${WEBRTC_BRANCH_HEAD}"
      ERROR "Unable to checkout ${WEBRTC_BRANCH_HEAD}"
  )

  libwebrtc_execute(
      COMMAND ${GIT_EXECUTABLE} log -1 --format=%H
      OUTPUT_VARIABLE _WEBRTC_SHA1
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/webrtc/src
      STAMPFILE
      STATUS "Get commit sha1 for ${WEBRTC_BRANCH_HEAD}"
      ERROR "Unable to get commit sha1 for ${WEBRTC_BRANCH_HEAD}"
  )
  string(STRIP ${_WEBRTC_SHA1} _WEBRTC_SHA1)
  set(LIBWEBRTC_WEBRTC_REVISION "${_WEBRTC_SHA1}")
  get_filename_component(LIBWEBRTC_WEBRTC_BRANCH_NAME "${WEBRTC_BRANCH_HEAD}" NAME)
endif (WEBRTC_REVISION)

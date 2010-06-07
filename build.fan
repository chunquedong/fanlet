#! /usr/bin/env fan

////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2010 Liam Staskawicz
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

using build

**
** Build: servlet
**
class Build : BuildPod
{
  new make()
  {
    podName  = "servlet"
    summary  = "Fantom support for (java) servlet containers"
    depends  = ["sys 1.0", "web 1.0", "inet 1.0", "concurrent 1.0"]
    srcDirs  = [`fan/`]
    javaDirs = [`java/`]
    docSrc   = true
  }
}

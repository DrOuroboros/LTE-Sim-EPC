#Compiliation tool
CXX = g++
#Flags
CXXFLAGS = -c --std=c++14 -Wall -Wno-unused-variable -Wno-unused-function -Wunused-but-set-variable -fPIC
#RM command add flags as needed
RM	= rm -f

#Compiled binary name
TARGET := 'ltesim'

#.o folders storage
OBJDIR  := .objects

#Select all .cpp files
SRC_FILES_cpp = $(shell find src/ -path -prune -o -name '*.cpp' -print)
OBJECTS_cpp = $(addprefix $(OBJDIR)/,$(SRC_FILES_cpp:.cpp=.o))
#Select all .cc files
SRC_FILES_cc = $(shell find src/ -path -prune -o -name '*.cc' -print)
OBJECTS_cc = $(addprefix $(OBJDIR)/,$(SRC_FILES_cc:.cc=.o))

all: $(TARGET)
#Build all of the .cpp files and .cc files, then link them
$(TARGET): $(OBJECTS_cpp) $(OBJECTS_cc) 
	@echo ''
	$(CXX) $^ -o $@
	@printf "\n\nBinary '%s' compiled, use './%s' to invoke\n" $@ $@
#Build all .cpp files, place them in .objects/<originalfilepath>.o
$(OBJECTS_cpp): $(OBJDIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@
#Build all .cc files, place them in .objects/<originalfilepath>.o
$(OBJECTS_cc): $(OBJDIR)/%.o: %.cc
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

#Add the pre-built .o files to our build
-include $(OBJECTS_cpp:.o=.d)	
-include $(OBJECTS_cc:.o=.d)

clean:
	@$(RM) $(TARGET)
	@$(RM) -R $(OBJDIR)

/*
 Copyright 2009, Arash Payan (http://arashpayan.com)
 This library is distributed under the terms of the GNU Lesser GPL.
 
 This file is part of APXML.
 
 APXML is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 APXML is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with APXML.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "APElement.h"
#import "APAttribute.h"


@implementation APElement

@synthesize name;
@synthesize parent;

+ (id)elementWithName:(NSString*)aName {
	return [[[APElement alloc] initWithName:aName] autorelease];
}

+ (id)elementWithName:(NSString*)aName attributes:(NSDictionary*)someAttributes {
	APElement *anElement = [[[APElement alloc] initWithName:aName] autorelease];
	[anElement addAttributes:someAttributes];
	
	return anElement;
}

- (id)initWithName:(NSString*)aName {
	if (self = [super init])
	{
		name = [[NSString alloc] initWithString:aName];
		//value = [[NSMutableString alloc] init];
		parent  = nil;
		attributes = [[NSMutableDictionary alloc] init];
		childElements = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addAttribute:(APAttribute*)anAttribute {
	[attributes setObject:anAttribute.value forKey:anAttribute.name];
}

- (void)addAttributeNamed:(NSString*)aName withValue:(NSString*)aValue {
	[attributes setObject:aValue forKey:aName];
}

/*
 All keys and values in the supplied dictionary must be of type NSString*
 */
- (void)addAttributes:(NSDictionary*)someAttributes {
	if (someAttributes != nil)
	{
		[attributes addEntriesFromDictionary:someAttributes];
	}
}

- (void)addChild:(APElement*)anElement {
	[childElements addObject:anElement];
}

- (void)appendValue:(NSString*)aValue {
	if (value == nil)
		value = [[NSMutableString alloc] init];
	
	[value appendString:aValue];
}

- (int)attributeCount {
	return [attributes count];
}

- (int)childCount {
	return [childElements count];
}

- (NSArray*)childElements {
	return [NSArray arrayWithArray:childElements];
}

- (NSMutableArray*)childElements:(NSString*)aName {
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	
	int numElements = [childElements count];
	for (int i=0; i<numElements; i++)
	{
		APElement *currElement = [childElements objectAtIndex:i];
		if ([currElement.name isEqual:aName])
			[result addObject:currElement];
	}
	
	return result;
}

- (APElement*)firstChildElement {
	if ([childElements count] > 0)
		return [childElements objectAtIndex:0];
	else
		return nil;
}

- (APElement*)firstChildElementNamed:(NSString*)aName {
	int numElements = [childElements count];
	for (int i=0; i<numElements; i++)
	{
		APElement *currElement = [childElements objectAtIndex:i];
		if ([currElement.name isEqual:aName])
			return currElement;
	}
	
	return nil;
}

- (NSString*)value {
	if (value == nil)
		return nil;
	else
		return [NSString stringWithString:value];
}

- (NSString*)valueForAttributeNamed:(NSString*)aName {
	return [attributes objectForKey:aName];
}

- (NSString*)description {
	return name;
}

- (NSString*)prettyXML:(int)tabs {
	NSMutableString *xmlResult = [[[NSMutableString alloc] init] autorelease];
	// append open bracket and element name
	for (int i=0; i<tabs; i++)
		[xmlResult appendFormat:@"\t"];
	[xmlResult appendFormat:@"<%@", name];
	
	for (NSString *key in attributes)
	{
		[xmlResult appendFormat:@" %@=\"%@\"", key, [attributes objectForKey:key]];
	}
	
	int numChildren = [childElements count];
	if (numChildren == 0 && value == nil)
	{
		[xmlResult appendFormat:@" />\n"];
		return xmlResult;
	}
	
	if (numChildren != 0)
	{
		[xmlResult appendString:@">\n"];
		for (int i=0; i<numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:i] prettyXML:(tabs+1)]];
		for (int i=0; i<tabs; i++)
			[xmlResult appendFormat:@"\t"];
		[xmlResult appendFormat:@"</%@>\n", name];
		
		return xmlResult;
	}
	else	// there must be a value
	{
		[xmlResult appendFormat:@">%@</%@>\n", [self encodeEntities:value], name];
		return xmlResult;
	}
}

- (NSString*)xml {
	NSMutableString *xmlResult = [[[NSMutableString alloc] init] autorelease];
	// append open bracket and element name
	[xmlResult appendFormat:@"<%@", name];
	
	for (NSString *key in attributes)
	{
		[xmlResult appendFormat:@" %@=\"%@\"", key, [attributes objectForKey:key]];
	}
	
	// append closing bracket and value
	int numChildren = [childElements count];
	if (numChildren == 0 && value == nil)
	{
		[xmlResult appendFormat:@"/>"];
		return xmlResult;
	}
	
	if (numChildren != 0)
	{
		[xmlResult appendString:@">"];
		for (int i=0; i<numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:i] xml]];
		[xmlResult appendFormat:@"</%@>", name];

		return xmlResult;
	}
	else	// there must be a value
	{
		[xmlResult appendFormat:@">%@</%@>", [self encodeEntities:value], name];
		return xmlResult;
	}
}

- (NSString*)encodeEntities:(NSMutableString*)aString {
	if (aString == nil || [aString length] == 0)
		return nil;
	
	NSMutableString *result = [[NSMutableString alloc] init];
	[result appendString:aString];
	[result replaceOccurrencesOfString:@"&"
							withString:@"&amp;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"<"
							withString:@"&lt;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@">"
							withString:@"&gt;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"'"
							withString:@"&apos;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"\""
							withString:@"&quot;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	
	return result;
}

- (void)dealloc {
	[name release];
	[value release];
	[parent release];
	[attributes release];
	[childElements release];
	
	[super dealloc];
}

@end

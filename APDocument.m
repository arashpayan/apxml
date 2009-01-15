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

#import "APDocument.h"
#import "APElement.h"

@interface APXMLBuilder : NSObject
{
	APElement *rootElement;
	APElement *openElement;
	APElement *parentElement;
}

- (APElement*)rootElement;

@end

@implementation APXMLBuilder

- (id)init {
	if (self = [super init])
	{
		rootElement = nil;
		openElement = nil;
		parentElement = nil;
	}
	
	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	APElement *newElement = [APElement elementWithName:elementName attributes:attributeDict];
	if (rootElement == nil)
		rootElement = [newElement retain];
	
	if (openElement != nil)
	{
		newElement.parent = openElement;
		parentElement = openElement;
		openElement = newElement;
	}
	else
	{
		newElement.parent = parentElement;
		openElement = newElement;
	}
	if (parentElement != nil)
		[parentElement addChild:openElement];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (openElement != nil)
	{
		openElement = parentElement;
		parentElement = parentElement.parent;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[openElement appendValue:string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
}

- (APElement*)rootElement {
	return rootElement;
}

- (void) dealloc
{
	[rootElement release];
	
	[super dealloc];
}


@end





@implementation APDocument

+ (id)documentWithXMLString:(NSString*)anXMLString {
	return [[[APDocument alloc] initWithString:anXMLString] autorelease];
}

- (id)initWithRootElement:(APElement*)aRootElement {
	if (self = [super init])
	{
		rootElement = [aRootElement retain];
	}
	
	return self;
}

- (id)initWithString:(NSString*)anXMLString {
	if (self = [super init])
	{
		APXMLBuilder *builder = [[APXMLBuilder alloc] init];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[anXMLString dataUsingEncoding:NSUTF8StringEncoding]];
		[parser setDelegate:builder];
		[parser parse];
		
		rootElement = [[builder rootElement] retain];
		
		[builder release];
		[parser release];
	}
	
	return self;
}

- (APElement*)rootElement {
	return rootElement;
}

- (NSString*)prettyXML {
	if (rootElement != nil)
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement prettyXML:0]];
		return result;
	}
	else
		return nil;
}

- (NSString*)xml {
	if (rootElement != nil)
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement xml]];
		return result;
	}
	else
		return nil;
}

- (void) dealloc
{
	[rootElement release];
	
	[super dealloc];
}


@end
